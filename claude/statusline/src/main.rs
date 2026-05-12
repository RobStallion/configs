// Claude Code statusline.
// Source of truth: ~/code/personal/my-configs/claude/statusline/src/main.rs
// Compiled binary symlinked to ~/.claude/statusline-command and invoked from settings.json.
//
// Layout:
//   <model>  $<cost>  ctx:<pct>%  eff:<level>  5h:<pct>%  [CAVEMAN]
//
// Model is read from the transcript (the model the upstream API actually served),
// not from payload.model.id (which is whatever alias Claude Code asked for).
// Rate-limit warning shown only when >=75%.

use serde_json::Value;
use std::env;
use std::fs;
use std::io::{self, Read, Seek, SeekFrom};
use std::path::Path;

const RESET: &str = "\x1b[0m";
const C_MODEL: &str = "\x1b[36m";
const C_COST: &str = "\x1b[33m";
const C_GOOD: &str = "\x1b[32m";
const C_WARN: &str = "\x1b[33m";
const C_BAD: &str = "\x1b[31m";
const C_EFFORT: &str = "\x1b[35m";
const C_CAVEMAN: &str = "\x1b[38;5;172m";

// Read at most this many bytes from the end of the transcript when scanning for
// the most recent assistant message. Bounds work on long sessions.
const TRANSCRIPT_TAIL_BYTES: u64 = 64 * 1024;

fn main() {
    let mut input = String::new();
    if io::stdin().read_to_string(&mut input).is_err() {
        return;
    }

    let payload: Value = match serde_json::from_str(&input) {
        Ok(v) => v,
        Err(_) => return,
    };

    let mut parts: Vec<String> = Vec::new();

    // Model: prefer real model from transcript, fall back to payload alias.
    let alias_model = extract_model_id(&payload);
    let transcript_path = payload
        .get("transcript_path")
        .and_then(|v| v.as_str())
        .unwrap_or("");
    let real_model = if transcript_path.is_empty() {
        String::new()
    } else {
        find_real_model(transcript_path).unwrap_or_default()
    };
    let model = if real_model.is_empty() { alias_model } else { real_model };
    if !model.is_empty() {
        let short = model.strip_prefix("claude-").unwrap_or(&model);
        parts.push(format!("{C_MODEL}{short}{RESET}"));
    }

    if let Some(cost) = payload
        .pointer("/cost/total_cost_usd")
        .and_then(|v| v.as_f64())
    {
        if cost >= 0.0 {
            parts.push(format!("{C_COST}${cost:.2}{RESET}"));
        }
    }

    if let Some(pct) = payload
        .pointer("/context_window/used_percentage")
        .and_then(|v| v.as_f64())
    {
        if pct >= 0.0 {
            let pct_int = pct as u64;
            let col = if pct_int >= 80 {
                C_BAD
            } else if pct_int >= 50 {
                C_WARN
            } else {
                C_GOOD
            };
            parts.push(format!("{col}ctx:{pct_int}%{RESET}"));
        }
    }

    if let Some(eff) = payload
        .pointer("/effort/level")
        .and_then(|v| v.as_str())
    {
        if !eff.is_empty() {
            parts.push(format!("{C_EFFORT}eff:{eff}{RESET}"));
        }
    }

    if let Some(s) = rate_warn(&payload, "/rate_limits/five_hour/used_percentage", "5h") {
        parts.push(s);
    }
    if let Some(s) = rate_warn(&payload, "/rate_limits/seven_day/used_percentage", "7d") {
        parts.push(s);
    }

    if let Some(home) = env::var_os("HOME") {
        let flag = Path::new(&home).join(".claude/.caveman-active");
        if flag.exists() {
            let mode = fs::read_to_string(&flag).unwrap_or_default();
            let mode = mode.trim();
            let badge = if mode.is_empty() || mode == "full" {
                "[CAVEMAN]".to_string()
            } else {
                format!("[CAVEMAN:{}]", mode.to_uppercase())
            };
            parts.push(format!("{C_CAVEMAN}{badge}{RESET}"));
        }
    }

    print!("{}", parts.join(" "));
}

fn extract_model_id(payload: &Value) -> String {
    match payload.get("model") {
        Some(Value::Object(o)) => o
            .get("id")
            .and_then(|v| v.as_str())
            .unwrap_or("")
            .to_string(),
        Some(Value::String(s)) => s.clone(),
        _ => String::new(),
    }
}

// Read tail of transcript and return model id from the most recent
// "type":"assistant" line. Seeking past the start of the file may land us mid
// UTF-8 codepoint, so we drop the first (partial) line before parsing.
fn find_real_model(path: &str) -> Option<String> {
    let mut file = fs::File::open(path).ok()?;
    let len = file.metadata().ok()?.len();
    let start = len.saturating_sub(TRANSCRIPT_TAIL_BYTES);
    file.seek(SeekFrom::Start(start)).ok()?;
    let mut buf = Vec::new();
    file.read_to_end(&mut buf).ok()?;

    let slice: &[u8] = if start == 0 {
        &buf
    } else {
        match buf.iter().position(|&b| b == b'\n') {
            Some(idx) => &buf[idx + 1..],
            None => return None,
        }
    };

    let s = String::from_utf8_lossy(slice);
    for line in s.lines().rev() {
        if !line.contains(r#""type":"assistant""#) {
            continue;
        }
        if let Ok(v) = serde_json::from_str::<Value>(line) {
            if let Some(m) = v.pointer("/message/model").and_then(|v| v.as_str()) {
                return Some(m.to_string());
            }
        }
    }
    None
}

fn rate_warn(payload: &Value, ptr: &str, label: &str) -> Option<String> {
    let pct = payload.pointer(ptr).and_then(|v| v.as_f64())?;
    if pct < 0.0 {
        return None;
    }
    let pct_int = pct as u64;
    if pct_int < 75 {
        return None;
    }
    let col = if pct_int >= 90 { C_BAD } else { C_WARN };
    Some(format!("{col}{label}:{pct_int}%{RESET}"))
}
