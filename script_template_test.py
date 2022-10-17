#!/usr/bin/env python3

import unittest
from unittest.mock import MagicMock

import script_template


class Testing(unittest.TestCase):
    def test_math(self):
        self.assertEqual(2, 1+1)

    def test_files(self):
        script_template.subprocess = MagicMock()
        script_template.subprocess.check_call = MagicMock()

        script_template.list_files(["hej"], dry_run=False)
        script_template.subprocess.check_call.assert_called_with(["ls", "-la", "hej"])

    def test_hello(self):
        script_template.print = MagicMock()

        script_template.hello("world", None, None, 1)

        script_template.print.assert_called_with("Hello", "world!")

    def test_mock_side_lookup(self):
        add_one = MagicMock(side_effect={1: 2, 2: 3}.__getitem__)

        self.assertEqual(2, add_one(1))
        self.assertEqual(3, add_one(2))
        self.assertRaises(KeyError, lambda: add_one(3))

    def test_mock_side_lookup2(self):
        plus = MagicMock(side_effect=lambda a, b: {(1, 2): 3}[(a, b)])

        self.assertEqual(3, plus(1, 2))

    def test_mock_list(self):
        gimmie = MagicMock(side_effect=[1, 2])
        self.assertEqual(1, gimmie())
        self.assertEqual(2, gimmie())
        self.assertRaises(StopIteration, gimmie)


if __name__ == '__main__':
    unittest.main()
