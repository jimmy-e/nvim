#!/bin/bash
# Manual Python parser installation for nvim-treesitter

echo "Installing Python parser manually..."

cd /tmp
rm -rf tree-sitter-python
git clone https://github.com/tree-sitter/tree-sitter-python.git
cd tree-sitter-python

# Compile the parser
echo "Compiling parser..."
cc -o parser.so -I./src src/parser.c src/scanner.c -shared -Os -lstdc++ -fPIC

# Copy to neovim location
mkdir -p ~/.local/share/nvim/site/parser
cp parser.so ~/.local/share/nvim/site/parser/python.so

echo "Done! Restart Neovim and Python highlighting should work."

