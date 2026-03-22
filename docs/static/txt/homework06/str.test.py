#!/usr/bin/env python3

import ctypes
import math
import unittest

# Str Utilities - Library

libstr = ctypes.CDLL('./libstr.so')
BUFSIZ = (1<<12)

# Str Utilities - Test Case

class StrTestCase(unittest.TestCase):
    Total  = 6
    Points = 0

    @classmethod
    def setUpClass(cls):
        print('Testing libstr.so ...')

    @classmethod
    def tearDownClass(cls):
        print()
        print(f'   Score {cls.Points:0.2f} / {cls.Total:0.2f}')
        print(f'   Grade {cls.Points/cls.Total:.2f} / {1.0:.2f}')
        print(f'  Status {"Success" if math.isclose(cls.Points, cls.Total) else "Failure"}')
        print()

    def test_00_str_lower(self):
        words = [b'', b' ', b'abc', b'ABC', b'AbC']
        for source in map(ctypes.create_string_buffer, words):
            target = source.value.lower()
            writer = ctypes.create_string_buffer(BUFSIZ)
            libstr.str_lower(source, writer)
            self.assertTrue(writer.value == target)
            StrTestCase.Points += 1.0 / len(words)

    def test_01_str_upper(self):
        words = [b'', b' ', b'abc', b'ABC', b'AbC']
        for source in map(ctypes.create_string_buffer, words):
            target = source.value.upper()
            writer = ctypes.create_string_buffer(BUFSIZ)
            libstr.str_upper(source, writer)
            self.assertTrue(writer.value == target)
            StrTestCase.Points += 1.0 / len(words)

    def test_02_str_title(self):
        words = [b'', b'abc', b'ABC', b'AbC', b'a b c', b'aa b0b c!!c']
        for source in map(ctypes.create_string_buffer, words):
            target = source.value.title()
            writer = ctypes.create_string_buffer(BUFSIZ)
            libstr.str_title(source, writer)
            self.assertTrue(writer.value == target)
            StrTestCase.Points += 1.0 / len(words)

    def test_03_str_rstrip(self):
        words = [b'', b'\n', b' abc ', b' abc\n', b'\na b c']
        for source in map(ctypes.create_string_buffer, words):
            target = source.value.rstrip()
            writer = ctypes.create_string_buffer(BUFSIZ)
            libstr.str_rstrip(source, None, writer)
            self.assertTrue(writer.value == target)
            StrTestCase.Points += 0.5 / len(words)

        for source in map(ctypes.create_string_buffer, words):
            target = source.value.rstrip(b'\n')
            writer = ctypes.create_string_buffer(BUFSIZ)
            chars  = ctypes.create_string_buffer(b'\n')
            libstr.str_rstrip(source, chars, writer)
            self.assertTrue(writer.value == target)
            StrTestCase.Points += 0.5 / len(words)

    def test_04_str_delete(self):
        cases = [
            (b'', b''),
            (b'hello', b''),
            (b'hello', b'le'),
            (b'hello world', b'le'),
            (b' hello world ', b' aeiou'),
        ]
        for source, chars in cases:
            source = ctypes.create_string_buffer(source)
            target = source.value.decode().translate({c: None for c in chars}).encode()
            writer = ctypes.create_string_buffer(BUFSIZ)
            libstr.str_delete(source, chars, writer)
            self.assertTrue(writer.value == target)
            StrTestCase.Points += 1.0 / len(cases)

    def test_05_str_translate(self):
        cases = [
            (b'', b'', b''),
            (b'hello', b'', b'430'),
            (b'hello', b'aeo', b''),
            (b'hello', b'aeo', b'430'),
            (b' hello ', b'aeo', b'430'),
            (b' hello ', b'aeol', b'4301'),
            (b' hello ', b'oleh', b'ymam'),
        ]
        for source, fr, to in cases:
            source = ctypes.create_string_buffer(source)
            target = source.value.decode().translate({f: t for f, t in zip(fr, to)}).encode()
            writer = ctypes.create_string_buffer(BUFSIZ)
            libstr.str_translate(source, fr, to, writer)
            self.assertTrue(writer.value == target)
            StrTestCase.Points += 1.0 / len(cases)

# Main Execution

if __name__ == '__main__':
    unittest.main()
