#!/usr/bin/ruby

# This file is out of date and does not appear to be used by current versions of
# markdownlint. See .markdownlint.json.

# Enable all rules by default
# all

## Exclude line length test
exclude_rule 'MD013'

# Commenting out, but saving for later - we're still getting errors for length
# Extend line length, since each sentence should be on a separate line.
rule 'MD013', :line_length => 99999, :ignore_code_blocks => true

# Allow in-line HTML
exclude_rule 'MD033'

# Nested lists should be indented with two spaces.
rule 'MD007', :indent => 2

# Bash defaulting confuses this and now way to ignore code blocks
exclude_rule 'MD029'
