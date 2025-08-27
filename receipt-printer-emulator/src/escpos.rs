use std::collections::VecDeque;

pub struct EscPosParser {
    width: usize,
    current_line: String,
    output: Vec<String>,
    
    // Text formatting states
    bold: bool,
    underline: u8,
    double_width: bool,
    double_height: bool,
    inverse: bool,
    alignment: Alignment,
    
    // Parser state
    buffer: VecDeque<u8>,
}

#[derive(Clone, Copy, PartialEq)]
enum Alignment {
    Left,
    Center,
    Right,
}

impl EscPosParser {
    pub fn new(width: usize) -> Self {
        Self {
            width,
            current_line: String::new(),
            output: Vec::new(),
            bold: false,
            underline: 0,
            double_width: false,
            double_height: false,
            inverse: false,
            alignment: Alignment::Left,
            buffer: VecDeque::new(),
        }
    }
    
    pub fn process(&mut self, data: &[u8]) {
        self.buffer.extend(data);
        
        while !self.buffer.is_empty() {
            if let Some(byte) = self.buffer.pop_front() {
                self.process_byte(byte);
            }
        }
    }
    
    pub fn get_output(&self) -> Vec<String> {
        let mut result = self.output.clone();
        
        // Add current line if not empty
        if !self.current_line.is_empty() {
            result.push(self.format_line(&self.current_line));
        }
        
        result
    }
    
    pub fn clear(&mut self) {
        self.current_line.clear();
        self.output.clear();
        self.buffer.clear();
        self.reset_formatting();
    }
    
    fn process_byte(&mut self, byte: u8) {
        match byte {
            0x1B => self.process_esc_sequence(),
            0x1D => self.process_gs_sequence(),
            0x0A | 0x0D => self.line_feed(),
            b if b >= 0x20 && b <= 0x7E => {
                self.current_line.push(b as char);
            }
            _ => {} // Ignore other control characters
        }
    }
    
    fn process_esc_sequence(&mut self) {
        if let Some(cmd) = self.buffer.pop_front() {
            match cmd {
                b'@' => self.init_printer(),
                b'!' => self.set_print_mode(),
                b'E' => self.set_emphasis(),
                b'-' => self.set_underline(),
                b'a' => self.set_justification(),
                b'd' => self.print_and_feed_lines(),
                b'2' => {}, // Default line spacing
                b'3' => self.set_line_spacing(),
                b'J' => self.print_and_feed_dots(),
                b'M' => self.select_font(),
                b'G' => self.set_double_strike(),
                b'V' => self.turn_90_clockwise(),
                b'{' => self.set_upside_down(),
                _ => {} // Unknown command
            }
        }
    }
    
    fn process_gs_sequence(&mut self) {
        if let Some(cmd) = self.buffer.pop_front() {
            match cmd {
                b'!' => self.set_character_size(),
                b'B' => self.set_inverse(),
                b'V' => self.cut_paper(),
                b'h' => self.set_barcode_height(),
                b'w' => self.set_barcode_width(),
                b'H' => self.set_barcode_text_position(),
                b'k' => self.print_barcode(),
                b'(' => self.process_gs_group(),
                _ => {} // Unknown command
            }
        }
    }
    
    fn init_printer(&mut self) {
        self.reset_formatting();
        self.current_line.clear();
    }
    
    fn reset_formatting(&mut self) {
        self.bold = false;
        self.underline = 0;
        self.double_width = false;
        self.double_height = false;
        self.inverse = false;
        self.alignment = Alignment::Left;
    }
    
    fn set_print_mode(&mut self) {
        if let Some(n) = self.buffer.pop_front() {
            self.bold = (n & 0x08) != 0;
            self.double_height = (n & 0x10) != 0;
            self.double_width = (n & 0x20) != 0;
            self.underline = if (n & 0x80) != 0 { 1 } else { 0 };
        }
    }
    
    fn set_emphasis(&mut self) {
        if let Some(n) = self.buffer.pop_front() {
            self.bold = n == 1;
        }
    }
    
    fn set_underline(&mut self) {
        if let Some(n) = self.buffer.pop_front() {
            self.underline = n;
        }
    }
    
    fn set_justification(&mut self) {
        if let Some(n) = self.buffer.pop_front() {
            self.alignment = match n {
                1 => Alignment::Center,
                2 => Alignment::Right,
                _ => Alignment::Left,
            };
        }
    }
    
    fn set_character_size(&mut self) {
        if let Some(n) = self.buffer.pop_front() {
            self.double_width = (n & 0x10) != 0;
            self.double_height = (n & 0x01) != 0;
        }
    }
    
    fn set_inverse(&mut self) {
        if let Some(n) = self.buffer.pop_front() {
            self.inverse = n == 1;
        }
    }
    
    fn print_and_feed_lines(&mut self) {
        if let Some(n) = self.buffer.pop_front() {
            self.line_feed();
            for _ in 0..n {
                self.output.push(String::new());
            }
        }
    }
    
    fn print_and_feed_dots(&mut self) {
        if let Some(_n) = self.buffer.pop_front() {
            self.line_feed();
        }
    }
    
    fn set_line_spacing(&mut self) {
        let _ = self.buffer.pop_front(); // Consume but don't use for now
    }
    
    fn select_font(&mut self) {
        let _ = self.buffer.pop_front(); // Consume but don't use for now
    }
    
    fn set_double_strike(&mut self) {
        let _ = self.buffer.pop_front(); // Consume but don't use for now
    }
    
    fn turn_90_clockwise(&mut self) {
        let _ = self.buffer.pop_front(); // Consume but don't use for now
    }
    
    fn set_upside_down(&mut self) {
        let _ = self.buffer.pop_front(); // Consume but don't use for now
    }
    
    fn set_barcode_height(&mut self) {
        let _ = self.buffer.pop_front(); // Consume height value
    }
    
    fn set_barcode_width(&mut self) {
        let _ = self.buffer.pop_front(); // Consume width value
    }
    
    fn set_barcode_text_position(&mut self) {
        let _ = self.buffer.pop_front(); // Consume position value
    }
    
    fn print_barcode(&mut self) {
        if let Some(barcode_type) = self.buffer.pop_front() {
            let mut barcode_data = Vec::new();
            
            // Different handling based on barcode type
            if barcode_type <= 6 {
                // Format 1: null-terminated
                while let Some(b) = self.buffer.pop_front() {
                    if b == 0 {
                        break;
                    }
                    barcode_data.push(b);
                }
            } else {
                // Format 2: length-prefixed
                if let Some(len) = self.buffer.pop_front() {
                    for _ in 0..len {
                        if let Some(b) = self.buffer.pop_front() {
                            barcode_data.push(b);
                        }
                    }
                }
            }
            
            let barcode_str = String::from_utf8_lossy(&barcode_data);
            self.output.push(format!("[BARCODE: Type={}, Data={}]", barcode_type, barcode_str));
        }
    }
    
    fn process_gs_group(&mut self) {
        if let Some(cmd) = self.buffer.pop_front() {
            if cmd == b'k' {
                // QR code command
                self.process_qr_code();
            }
        }
    }
    
    fn process_qr_code(&mut self) {
        // Simplified QR code handling
        self.output.push("[QR CODE]".to_string());
        
        // Skip the QR code data for now
        while let Some(b) = self.buffer.pop_front() {
            if b == 0x1B || b == 0x1D {
                // Put it back and stop
                self.buffer.push_front(b);
                break;
            }
        }
    }
    
    fn cut_paper(&mut self) {
        self.flush_current_line();
        
        if let Some(m) = self.buffer.pop_front() {
            match m {
                0 | 48 => self.output.push("════════════════════════════════════════════════".to_string()),
                1 | 49 => self.output.push("- - - - - - - - - - - - - - - - - - - - - - - - ".to_string()),
                65 | 66 => {
                    // Feed and cut
                    if let Some(n) = self.buffer.pop_front() {
                        for _ in 0..n {
                            self.output.push(String::new());
                        }
                    }
                    self.output.push("════════════════════════════════════════════════".to_string());
                }
                _ => {}
            }
        }
    }
    
    fn line_feed(&mut self) {
        self.flush_current_line();
    }
    
    fn flush_current_line(&mut self) {
        if !self.current_line.is_empty() || true {
            let formatted = self.format_line(&self.current_line);
            self.output.push(formatted);
            self.current_line.clear();
        }
    }
    
    fn format_line(&self, text: &str) -> String {
        let mut formatted = text.to_string();
        
        // Apply formatting markers
        if self.bold {
            formatted = format!("**{}**", formatted);
        }
        
        if self.underline > 0 {
            formatted = format!("__{}__", formatted);
        }
        
        if self.inverse {
            formatted = format!("[INV]{}[/INV]", formatted);
        }
        
        if self.double_width {
            formatted = format!("[2W]{}[/2W]", formatted);
        }
        
        if self.double_height {
            formatted = format!("[2H]{}[/2H]", formatted);
        }
        
        // Apply alignment
        let display_len = self.calculate_display_length(&formatted);
        match self.alignment {
            Alignment::Center => {
                let padding = (self.width.saturating_sub(display_len)) / 2;
                format!("{:>width$}", formatted, width = display_len + padding)
            }
            Alignment::Right => {
                format!("{:>width$}", formatted, width = self.width)
            }
            Alignment::Left => formatted,
        }
    }
    
    fn calculate_display_length(&self, text: &str) -> usize {
        // Remove formatting markers for length calculation
        let mut clean = text.to_string();
        for marker in &["**", "__", "[INV]", "[/INV]", "[2W]", "[/2W]", "[2H]", "[/2H]"] {
            clean = clean.replace(marker, "");
        }
        clean.len()
    }
}