use anyhow::Result;
use chrono::Local;
use colored::*;
use std::fs;
use std::path::Path;

use crate::escpos::EscPosParser;
use crate::renderer::ReceiptRenderer;

pub struct VirtualPrinter {
    width: usize,
    parser: EscPosParser,
    renderer: ReceiptRenderer,
    output_mode: OutputMode,
    output_dir: String,
    receipt_count: usize,
}

#[derive(Clone)]
enum OutputMode {
    Console,
    File,
    Both,
}

impl VirtualPrinter {
    pub fn new(width: usize, output: &str, output_dir: &str) -> Result<Self> {
        let output_mode = match output.to_lowercase().as_str() {
            "file" => OutputMode::File,
            "both" => OutputMode::Both,
            _ => OutputMode::Console,
        };
        
        // Create output directory if needed
        if matches!(output_mode, OutputMode::File | OutputMode::Both) {
            fs::create_dir_all(output_dir)?;
        }
        
        Ok(Self {
            width,
            parser: EscPosParser::new(width),
            renderer: ReceiptRenderer::new(width),
            output_mode,
            output_dir: output_dir.to_string(),
            receipt_count: 0,
        })
    }
    
    pub fn process_data(&mut self, data: &[u8]) -> Result<()> {
        self.parser.process(data);
        Ok(())
    }
    
    pub fn render_receipt(&mut self) -> Result<()> {
        let lines = self.parser.get_output();
        if lines.is_empty() {
            return Ok(());
        }
        
        self.receipt_count += 1;
        let timestamp = Local::now();
        
        match self.output_mode {
            OutputMode::Console | OutputMode::Both => {
                self.render_to_console(&lines, self.receipt_count, &timestamp);
            }
            _ => {}
        }
        
        match self.output_mode {
            OutputMode::File | OutputMode::Both => {
                self.render_to_file(&lines, self.receipt_count, &timestamp)?;
            }
            _ => {}
        }
        
        // Clear the parser for next receipt
        self.parser.clear();
        
        Ok(())
    }
    
    fn render_to_console(&self, lines: &[String], receipt_num: usize, timestamp: &chrono::DateTime<Local>) {
        println!();
        println!("{}", "┌─────────────────────────────────────────────────┐".bright_white());
        println!("{} {} {} {}",
            "│".bright_white(),
            format!("RECEIPT #{:04}", receipt_num).bright_yellow().bold(),
            format!("[{}]", timestamp.format("%Y-%m-%d %H:%M:%S")).bright_black(),
            " ".repeat(48 - 25 - timestamp.format("%Y-%m-%d %H:%M:%S").to_string().len()) + &"│".bright_white().to_string()
        );
        println!("{}", "├─────────────────────────────────────────────────┤".bright_white());
        
        for line in lines {
            let rendered = self.renderer.render_line(line);
            let display_width = strip_ansi_codes(&rendered).chars().count();
            let padding = if display_width < self.width {
                self.width - display_width
            } else {
                0
            };
            
            println!("{} {}{} {}",
                "│".bright_white(),
                rendered,
                " ".repeat(padding),
                "│".bright_white()
            );
        }
        
        println!("{}", "└─────────────────────────────────────────────────┘".bright_white());
        println!("{}", "  ✂️ CUT ✂️".bright_red());
        println!();
    }
    
    fn render_to_file(&self, lines: &[String], receipt_num: usize, timestamp: &chrono::DateTime<Local>) -> Result<()> {
        let filename = format!("receipt_{:04}_{}.txt", 
            receipt_num, 
            timestamp.format("%Y%m%d_%H%M%S")
        );
        let filepath = Path::new(&self.output_dir).join(&filename);
        
        let mut content = String::new();
        content.push_str(&format!("RECEIPT #{:04}\n", receipt_num));
        content.push_str(&format!("Date: {}\n", timestamp.format("%Y-%m-%d %H:%M:%S")));
        content.push_str(&"=".repeat(self.width));
        content.push('\n');
        
        for line in lines {
            content.push_str(&self.renderer.render_plain_text(line));
            content.push('\n');
        }
        
        content.push_str(&"=".repeat(self.width));
        content.push_str("\n--- CUT ---\n");
        
        fs::write(&filepath, content)?;
        println!("{} {}", "  📄 Receipt saved to:".bright_green(), filepath.display().to_string().bright_white());
        
        Ok(())
    }
}

fn strip_ansi_codes(s: &str) -> String {
    let mut result = String::new();
    let mut chars = s.chars().peekable();
    
    while let Some(ch) = chars.next() {
        if ch == '\x1b' {
            // Skip ANSI escape sequence
            if chars.peek() == Some(&'[') {
                chars.next(); // consume '['
                // Skip until we find a letter
                while let Some(c) = chars.next() {
                    if c.is_alphabetic() {
                        break;
                    }
                }
            }
        } else {
            result.push(ch);
        }
    }
    
    result
}