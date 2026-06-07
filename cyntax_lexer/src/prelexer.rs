use std::str::Chars;

use cyntax_common::spanned::{Location, Spanned};
use peekmore::{PeekMore, PeekMoreIterator};

#[derive(Debug)]
pub struct PrelexerIter<'src> {
    file_id: usize,
    chars: PeekMoreIterator<Chars<'src>>,
    /// The end of the previous character
    current_pos: usize,
}
impl<'src> PrelexerIter<'src> {
    pub fn new(file_id: usize, source: &'src str) -> PrelexerIter<'src> {
        PrelexerIter {
            file_id,
            chars: source.chars().peekmore(),
            current_pos: 0,
        }
    }
}
impl<'src> Iterator for PrelexerIter<'src> {
    type Item = Spanned<char>;

    /// Get the next character, including a Range<usize> of bytes into the original string.
    /// If the character is a backslash `\`, and next character is a newline `\n`, they are skipped
    /// If the next two characters are ??, and the one after those is a valid trigraph character, all 3 are skipped and a replacement character is returned
    fn next(&mut self) -> Option<Self::Item> {
        let start = self.current_pos;

        let mut current_character = self.chars.next()?;
        let mut length = current_character.len_utf8();

        match (current_character, self.chars.peek()) {
            ('<', Some(':')) => {
                length += self.chars.next().unwrap().len_utf8();
                current_character = '[';
            }
            (':', Some('>')) => {
                length += self.chars.next().unwrap().len_utf8();
                current_character = ']';
            }
            ('<', Some('%')) => {
                length += self.chars.next().unwrap().len_utf8();
                current_character = '{';
            }
            ('%', Some('>')) => {
                length += self.chars.next().unwrap().len_utf8();
                current_character = '}';
            }
            ('%', Some(':')) => {
                length += self.chars.next().unwrap().len_utf8();
                current_character = '#';
            }

            _ => {}
        }
        // Handle trigraphs
        if current_character == '?' && self.chars.peek() == Some(&'?') {
            let trigaph_replacement = match self.chars.peek_nth(1) {
                Some('=') => Some('#'),
                Some('/') => Some('\\'),
                Some('\'') => Some('^'),
                Some('(') => Some('['),
                Some(')') => Some(']'),
                Some('!') => Some('|'),
                Some('<') => Some('{'),
                Some('>') => Some('}'),
                Some('-') => Some('~'),

                Some(_) | None => None,
            };
            if let Some(replacement) = trigaph_replacement {
                length += self.chars.next().unwrap().len_utf8(); // Second ?
                length += self.chars.next().unwrap().len_utf8(); // Actual trigraph character

                current_character = replacement;
            }
        }

        if current_character == '\\' && self.chars.peek() == Some(&'\n') {
            length += self.chars.next().unwrap().len_utf8();

            self.current_pos = start + length; // \ and ?
            return self.next();
        } else {
            self.current_pos = start + length;
            return Some(Spanned::new(
                Location {
                    range: start..self.current_pos,
                    file_id: self.file_id,
                },
                current_character,
            ));
        }
    }
}
