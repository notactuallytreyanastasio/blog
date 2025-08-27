use colored::*;

pub struct ReceiptRenderer {
    width: usize,
}

impl ReceiptRenderer {
    pub fn new(width: usize) -> Self {
        Self { width }
    }
    
    pub fn render_line(&self, line: &str) -> String {
        let mut result = line.to_string();
        let mut formatted = String::new();
        let mut chars = result.chars().peekable();
        let mut in_marker = false;
        let mut marker = String::new();
        
        while let Some(ch) = chars.next() {
            if ch == '[' && !in_marker {
                // Start of a potential marker
                marker.clear();
                marker.push(ch);
                in_marker = true;
                
                // Look ahead to see if this is a marker
                let mut temp_marker = marker.clone();
                let mut temp_chars = chars.clone();
                while let Some(next_ch) = temp_chars.next() {
                    temp_marker.push(next_ch);
                    if next_ch == ']' {
                        break;
                    }
                    if temp_marker.len() > 10 {
                        // Not a marker, too long
                        in_marker = false;
                        formatted.push(ch);
                        break;
                    }
                }
                
                if !in_marker {
                    continue;
                }
            } else if in_marker {
                marker.push(ch);
                if ch == ']' {
                    // End of marker
                    in_marker = false;
                    
                    match marker.as_str() {
                        "[INV]" => {
                            // Start inverse text
                            formatted.push_str(&format!("{}", "".on_white().black()));
                        }
                        "[/INV]" => {
                            // End inverse text
                            formatted.push_str(&format!("{}", "".normal()));
                        }
                        "[2W]" => {
                            // Double width marker (visual hint)
                            formatted.push_str(&"".bold().to_string());
                        }
                        "[/2W]" => {
                            // End double width
                            formatted.push_str(&"".normal().to_string());
                        }
                        "[2H]" => {
                            // Double height marker
                            formatted.push_str(&"".bold().to_string());
                        }
                        "[/2H]" => {
                            // End double height
                            formatted.push_str(&"".normal().to_string());
                        }
                        _ if marker.starts_with("[BARCODE:") => {
                            formatted.push_str(&marker.bright_blue().to_string());
                        }
                        "[QR CODE]" => {
                            formatted.push_str(&"█▀▀▀▀▀█".bright_black().to_string());
                        }
                        _ => {
                            formatted.push_str(&marker);
                        }
                    }
                    marker.clear();
                }
            } else if ch == '*' && chars.peek() == Some(&'*') {
                // Bold text
                chars.next(); // consume second *
                let mut bold_text = String::new();
                let mut found_end = false;
                
                while let Some(next_ch) = chars.next() {
                    if next_ch == '*' && chars.peek() == Some(&'*') {
                        chars.next(); // consume second *
                        found_end = true;
                        break;
                    }
                    bold_text.push(next_ch);
                }
                
                if found_end {
                    formatted.push_str(&bold_text.bold().to_string());
                } else {
                    formatted.push_str("**");
                    formatted.push_str(&bold_text);
                }
            } else if ch == '_' && chars.peek() == Some(&'_') {
                // Underlined text
                chars.next(); // consume second _
                let mut underline_text = String::new();
                let mut found_end = false;
                
                while let Some(next_ch) = chars.next() {
                    if next_ch == '_' && chars.peek() == Some(&'_') {
                        chars.next(); // consume second _
                        found_end = true;
                        break;
                    }
                    underline_text.push(next_ch);
                }
                
                if found_end {
                    formatted.push_str(&underline_text.underline().to_string());
                } else {
                    formatted.push_str("__");
                    formatted.push_str(&underline_text);
                }
            } else if ch == '═' || ch == '─' {
                // Separator lines
                formatted.push_str(&ch.to_string().bright_white().to_string());
            } else {
                formatted.push(ch);
            }
        }
        
        // Handle any unclosed marker
        if in_marker {
            formatted.push_str(&marker);
        }
        
        formatted
    }
    
    pub fn render_plain_text(&self, line: &str) -> String {
        // Remove all formatting markers for plain text output
        let mut result = line.to_string();
        
        // Remove bold markers
        result = result.replace("**", "");
        
        // Remove underline markers
        result = result.replace("__", "");
        
        // Remove special markers
        for marker in &["[INV]", "[/INV]", "[2W]", "[/2W]", "[2H]", "[/2H]"] {
            result = result.replace(marker, "");
        }
        
        // Keep barcode and QR code indicators but simplify them
        if result.contains("[BARCODE:") {
            // Extract just the barcode info
            if let Some(start) = result.find("[BARCODE:") {
                if let Some(end) = result[start..].find(']') {
                    let barcode_info = &result[start..start+end+1];
                    result = result.replace(barcode_info, &format!(">>> {} <<<", barcode_info));
                }
            }
        }
        
        result
    }
}