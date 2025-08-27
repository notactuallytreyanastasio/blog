use anyhow::Result;
use bytes::BytesMut;
use chrono::Local;
use clap::Parser;
use colored::*;
use std::io::Write;
use std::sync::Arc;
use tokio::io::{AsyncReadExt, AsyncWriteExt};
use tokio::net::{TcpListener, TcpStream};
use tokio::sync::Mutex;

mod printer;
mod escpos;
mod renderer;

use printer::VirtualPrinter;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// TCP port to listen on
    #[arg(short, long, default_value = "9100")]
    port: u16,

    /// Output mode: console, file, or both
    #[arg(short, long, default_value = "console")]
    output: String,

    /// Directory for file output
    #[arg(short = 'd', long, default_value = "./receipts")]
    output_dir: String,

    /// Enable verbose logging
    #[arg(short, long)]
    verbose: bool,

    /// Paper width in characters
    #[arg(short = 'w', long, default_value = "48")]
    width: usize,

    /// Auto-cut after timeout (seconds)
    #[arg(short = 'c', long)]
    auto_cut_timeout: Option<u64>,
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = Args::parse();
    
    println!("{}", "═".repeat(60).bright_cyan());
    println!("{}", "    RECEIPT PRINTER EMULATOR".bright_cyan().bold());
    println!("{}", "═".repeat(60).bright_cyan());
    println!();
    println!("{} {}", "Port:".bright_yellow(), args.port);
    println!("{} {}", "Output:".bright_yellow(), args.output);
    println!("{} {} characters", "Width:".bright_yellow(), args.width);
    println!();
    println!("{}", "Waiting for connections...".bright_green());
    println!("{}", "─".repeat(60).bright_black());
    
    let listener = TcpListener::bind(format!("0.0.0.0:{}", args.port)).await?;
    let printer = Arc::new(Mutex::new(VirtualPrinter::new(args.width, &args.output, &args.output_dir)?));
    
    loop {
        let (stream, addr) = listener.accept().await?;
        let printer = Arc::clone(&printer);
        let verbose = args.verbose;
        let auto_cut_timeout = args.auto_cut_timeout;
        
        println!("\n{} {}", "► New connection from:".bright_green(), addr.to_string().bright_white());
        
        tokio::spawn(async move {
            if let Err(e) = handle_connection(stream, printer, verbose, auto_cut_timeout).await {
                eprintln!("{} {}", "Error handling connection:".bright_red(), e);
            }
            println!("{} {}", "◄ Connection closed:".bright_yellow(), addr.to_string().bright_white());
        });
    }
}

async fn handle_connection(
    mut stream: TcpStream,
    printer: Arc<Mutex<VirtualPrinter>>,
    verbose: bool,
    auto_cut_timeout: Option<u64>,
) -> Result<()> {
    let mut buffer = BytesMut::with_capacity(4096);
    let mut last_data_time = std::time::Instant::now();
    let mut job_buffer = Vec::new();
    
    loop {
        tokio::select! {
            // Read data from the connection
            result = stream.read_buf(&mut buffer) => {
                match result {
                    Ok(0) => {
                        // Connection closed
                        if !job_buffer.is_empty() {
                            let mut printer = printer.lock().await;
                            printer.process_data(&job_buffer)?;
                            printer.render_receipt()?;
                        }
                        break;
                    }
                    Ok(n) => {
                        if verbose {
                            println!("{} {} bytes", "  Received:".bright_black(), n);
                        }
                        
                        // Add data to job buffer
                        job_buffer.extend_from_slice(&buffer[..n]);
                        buffer.clear();
                        last_data_time = std::time::Instant::now();
                        
                        // Check for cut command (simplified detection)
                        if contains_cut_command(&job_buffer) {
                            let mut printer = printer.lock().await;
                            printer.process_data(&job_buffer)?;
                            printer.render_receipt()?;
                            job_buffer.clear();
                        }
                    }
                    Err(e) => {
                        eprintln!("Error reading from socket: {}", e);
                        break;
                    }
                }
            }
            
            // Auto-cut timeout
            _ = tokio::time::sleep(tokio::time::Duration::from_millis(100)) => {
                if let Some(timeout) = auto_cut_timeout {
                    if last_data_time.elapsed().as_secs() >= timeout && !job_buffer.is_empty() {
                        println!("{}", "  Auto-cutting due to timeout...".bright_yellow());
                        let mut printer = printer.lock().await;
                        printer.process_data(&job_buffer)?;
                        printer.render_receipt()?;
                        job_buffer.clear();
                    }
                }
            }
        }
    }
    
    Ok(())
}

fn contains_cut_command(data: &[u8]) -> bool {
    // Check for GS V commands (cut paper)
    for i in 0..data.len().saturating_sub(2) {
        if data[i] == 0x1D && data[i + 1] == b'V' {
            return true;
        }
    }
    false
}
