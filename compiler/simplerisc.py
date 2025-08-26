#!/usr/bin/env python3
"""
SimpleRISC Compiler
A readable language compiler for 32-bit RISC-V CPU

File extension: .tj (TJ's custom language)

Syntax:
    r1 = r2 + r3        # ADD
    r4 = r1 - r2        # SUB  
    r5 = r1 & r2        # AND
    r6 = r1 | r2        # OR
    r7 = r1 < r2        # SLT
    r1 = memory[0]      # LOAD
    memory[4] = r1      # STORE
    if r1 == r2:        # BEQ
        # code block
"""

import re
import sys
from enum import Enum
from dataclasses import dataclass
from typing import List, Union, Optional

# Token Types
class TokenType(Enum):
    REGISTER = "REGISTER"        
    NUMBER = "NUMBER"            
    MEMORY = "MEMORY"            
    LBRACKET = "LBRACKET"        
    RBRACKET = "RBRACKET"        
    ASSIGN = "ASSIGN"            
    PLUS = "PLUS"                
    MINUS = "MINUS"              
    AND = "AND"                  
    OR = "OR"                    
    LT = "LT"                    
    EQ = "EQ"                    
    IF = "IF"                    
    COLON = "COLON"              
    NEWLINE = "NEWLINE"          
    EOF = "EOF"                  
    DATA = "DATA"                
    COMMA = "COMMA"

@dataclass
class Token:
    type: TokenType
    value: str
    line: int = 0

# Lexer
class Lexer:
    def __init__(self, text: str):
        self.text = text
        self.pos = 0
        self.line = 1
        
    def error(self, message: str):
        raise SyntaxError(f"Line {self.line}: {message}")
        
    def peek(self, offset: int = 0) -> str:
        pos = self.pos + offset
        if pos >= len(self.text):
            return '\0'
        return self.text[pos]
    
    def advance(self) -> str:
        if self.pos < len(self.text):
            char = self.text[self.pos]
            self.pos += 1
            if char == '\n':
                self.line += 1
            return char
        return '\0'
    
    def skip_whitespace(self):
        while self.peek() in ' \t\r':
            self.advance()
    
    def skip_comment(self):
        if self.peek() == '#':
            while self.peek() != '\n' and self.peek() != '\0':
                self.advance()
    
    def read_number(self) -> str:
        num = ''
        while self.peek().isdigit():
            num += self.advance()
        return num
    
    def read_identifier(self) -> str:
        ident = ''
        while self.peek().isalnum() or self.peek() == '_':
            ident += self.advance()
        return ident
    
    def tokenize(self) -> List[Token]:
        tokens = []
        
        while self.pos < len(self.text):
            self.skip_whitespace()
            self.skip_comment()
            
            char = self.peek()
            
            if char == '\0':
                break
            elif char == '\n':
                tokens.append(Token(TokenType.NEWLINE, self.advance(), self.line))
            elif char == '=':
                self.advance()
                if self.peek() == '=':
                    self.advance()
                    tokens.append(Token(TokenType.EQ, '==', self.line))
                else:
                    tokens.append(Token(TokenType.ASSIGN, '=', self.line))
            elif char == '+':
                tokens.append(Token(TokenType.PLUS, self.advance(), self.line))
            elif char == '-':
                tokens.append(Token(TokenType.MINUS, self.advance(), self.line))
            elif char == '&':
                tokens.append(Token(TokenType.AND, self.advance(), self.line))
            elif char == '|':
                tokens.append(Token(TokenType.OR, self.advance(), self.line))
            elif char == '<':
                tokens.append(Token(TokenType.LT, self.advance(), self.line))
            elif char == '[':
                tokens.append(Token(TokenType.LBRACKET, self.advance(), self.line))
            elif char == ']':
                tokens.append(Token(TokenType.RBRACKET, self.advance(), self.line))
            elif char == ':':
                tokens.append(Token(TokenType.COLON, self.advance(), self.line))
            elif char == ',':
                tokens.append(Token(TokenType.COMMA, self.advance(), self.line))
            elif char.isdigit():
                num = self.read_number()
                tokens.append(Token(TokenType.NUMBER, num, self.line))
            elif char.isalpha():
                ident = self.read_identifier()
                if ident == 'memory':
                    tokens.append(Token(TokenType.MEMORY, ident, self.line))
                elif ident == 'if':
                    tokens.append(Token(TokenType.IF, ident, self.line))
                elif ident == 'data':
                    tokens.append(Token(TokenType.DATA, ident, self.line))
                elif ident.startswith('r') and ident[1:].isdigit():
                    tokens.append(Token(TokenType.REGISTER, ident, self.line))
                else:
                    self.error(f"Unknown identifier: {ident}")
            else:
                self.error(f"Unexpected character: {char}")
        
        tokens.append(Token(TokenType.EOF, '', self.line))
        return tokens

# AST Nodes
class ASTNode:
    pass

@dataclass
class Register(ASTNode):
    number: int

@dataclass
class Number(ASTNode):
    value: int

@dataclass
class MemoryAccess(ASTNode):
    address: Union[Number, Register]

@dataclass
class BinaryOp(ASTNode):
    left: ASTNode
    op: str
    right: ASTNode

@dataclass
class Assignment(ASTNode):
    target: Union[Register, MemoryAccess]
    source: ASTNode

@dataclass
class IfStatement(ASTNode):
    condition: BinaryOp
    body: List[ASTNode]

@dataclass
class DataDeclaration(ASTNode):
    values: List[int]

# Simple Parser
class Parser:
    def __init__(self, tokens: List[Token]):
        self.tokens = tokens
        self.pos = 0
    
    def peek(self) -> Token:
        if self.pos < len(self.tokens):
            return self.tokens[self.pos]
        return Token(TokenType.EOF, '', 0)
    
    def advance(self) -> Token:
        token = self.peek()
        if self.pos < len(self.tokens) - 1:
            self.pos += 1
        return token
    
    def parse(self) -> List[ASTNode]:
        statements = []
        while self.peek().type != TokenType.EOF:
            if self.peek().type == TokenType.NEWLINE:
                self.advance()
                continue
            stmt = self.parse_statement()
            if stmt:
                statements.append(stmt)
        return statements
    
    def parse_statement(self) -> Optional[ASTNode]:
        if self.peek().type == TokenType.REGISTER:
            return self.parse_assignment()
        elif self.peek().type == TokenType.MEMORY:
            return self.parse_memory_assignment()
        elif self.peek().type == TokenType.IF:
            return self.parse_if_statement()
        elif self.peek().type == TokenType.DATA:
            return self.parse_data_declaration()
        else:
            self.advance()  # Skip unknown tokens
            return None
    
    def parse_assignment(self) -> Assignment:
        # r1 = r2 + r3
        reg_token = self.advance()
        reg_num = int(reg_token.value[1:])
        target = Register(reg_num)
        
        self.advance()  # skip '='
        source = self.parse_expression()
        return Assignment(target, source)
    
    def parse_memory_assignment(self) -> Assignment:
        # memory[4] = r1
        self.advance()  # skip 'memory'
        self.advance()  # skip '['
        addr_token = self.advance()
        address = Number(int(addr_token.value))
        self.advance()  # skip ']'
        self.advance()  # skip '='
        
        source = self.parse_expression()
        return Assignment(MemoryAccess(address), source)
    
    def parse_expression(self) -> ASTNode:
        left = self.parse_primary()
        
        if self.peek().type in [TokenType.PLUS, TokenType.MINUS, TokenType.AND, TokenType.OR, TokenType.LT, TokenType.EQ]:
            op_token = self.advance()
            right = self.parse_primary()
            return BinaryOp(left, op_token.value, right)
        
        return left
    
    def parse_primary(self) -> ASTNode:
        if self.peek().type == TokenType.REGISTER:
            reg_token = self.advance()
            return Register(int(reg_token.value[1:]))
        elif self.peek().type == TokenType.NUMBER:
            num_token = self.advance()
            return Number(int(num_token.value))
        elif self.peek().type == TokenType.MEMORY:
            self.advance()  # skip 'memory'
            self.advance()  # skip '['
            addr_token = self.advance()
            self.advance()  # skip ']'
            return MemoryAccess(Number(int(addr_token.value)))
        
        return Number(0)  # Default fallback
    
    def parse_if_statement(self) -> IfStatement:
        self.advance()  # skip 'if'
        condition = self.parse_expression()
        self.advance()  # skip ':'
        
        # For now, just return empty body
        return IfStatement(condition, [])
    
    def parse_data_declaration(self) -> DataDeclaration:
        self.advance()  # skip 'data'
        values = []
        while self.peek().type == TokenType.NUMBER:
            values.append(int(self.advance().value))
            if self.peek().type == TokenType.COMMA:
                self.advance()
        return DataDeclaration(values)

# Code Generator
class CodeGenerator:
    def __init__(self):
        self.instructions = []
    
    def generate(self, ast: List[ASTNode]) -> List[str]:
        for node in ast:
            self.visit(node)
        return self.instructions
    
    def visit(self, node: ASTNode):
        if isinstance(node, Assignment):
            self.visit_assignment(node)
        elif isinstance(node, IfStatement):
            self.visit_if_statement(node)
        elif isinstance(node, DataDeclaration):
            self.visit_data_declaration(node)
    
    def visit_assignment(self, node: Assignment):
        if isinstance(node.target, Register):
            if isinstance(node.source, BinaryOp):
                self.generate_binary_op(node.target, node.source)
            elif isinstance(node.source, MemoryAccess):
                self.generate_load(node.target, node.source)
        elif isinstance(node.target, MemoryAccess):
            if isinstance(node.source, Register):
                self.generate_store(node.target, node.source)
    
    def generate_binary_op(self, target: Register, op: BinaryOp):
        if isinstance(op.left, Register) and isinstance(op.right, Register):
            rs1 = op.left.number
            rs2 = op.right.number
            rd = target.number
            
            if op.op == '+':
                # ADD rd, rs1, rs2
                self.instructions.append(self.encode_r_type(0b0110011, rd, 0b000, rs1, rs2, 0b0000000))
            elif op.op == '-':
                # SUB rd, rs1, rs2  
                self.instructions.append(self.encode_r_type(0b0110011, rd, 0b000, rs1, rs2, 0b0100000))
            elif op.op == '&':
                # AND rd, rs1, rs2
                self.instructions.append(self.encode_r_type(0b0110011, rd, 0b111, rs1, rs2, 0b0000000))
            elif op.op == '|':
                # OR rd, rs1, rs2
                self.instructions.append(self.encode_r_type(0b0110011, rd, 0b110, rs1, rs2, 0b0000000))
            elif op.op == '<':
                # SLT rd, rs1, rs2
                self.instructions.append(self.encode_r_type(0b0110011, rd, 0b010, rs1, rs2, 0b0000000))
    
    def generate_load(self, target: Register, mem: MemoryAccess):
        # LW rd, offset(rs1) - simplified to LW rd, offset(x0)
        rd = target.number
        if isinstance(mem.address, Number):
            offset = mem.address.value
            self.instructions.append(self.encode_i_type(0b0000011, rd, 0b010, 0, offset))
    
    def generate_store(self, mem: MemoryAccess, source: Register):
        # SW rs2, offset(rs1) - simplified to SW rs2, offset(x0)
        rs2 = source.number
        if isinstance(mem.address, Number):
            offset = mem.address.value
            self.instructions.append(self.encode_s_type(0b0100011, 0b010, 0, rs2, offset))
    
    def visit_if_statement(self, node: IfStatement):
        # BEQ rs1, rs2, offset (simplified - just encode BEQ for now)
        if isinstance(node.condition, BinaryOp) and node.condition.op == '==':
            if isinstance(node.condition.left, Register) and isinstance(node.condition.right, Register):
                rs1 = node.condition.left.number
                rs2 = node.condition.right.number
                # Simple forward branch of 4 (next instruction)
                self.instructions.append(self.encode_b_type(0b1100011, 0b000, rs1, rs2, 4))
    
    def visit_data_declaration(self, node: DataDeclaration):
        # Data declarations don't generate instructions, just note them
        pass
    
    def encode_r_type(self, opcode: int, rd: int, funct3: int, rs1: int, rs2: int, funct7: int) -> str:
        instruction = (funct7 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
        return f"{instruction:08X}"
    
    def encode_i_type(self, opcode: int, rd: int, funct3: int, rs1: int, imm: int) -> str:
        instruction = (imm << 20) | (rs1 << 15) | (funct3 << 12) | (rd << 7) | opcode
        return f"{instruction:08X}"
    
    def encode_s_type(self, opcode: int, funct3: int, rs1: int, rs2: int, imm: int) -> str:
        imm_11_5 = (imm >> 5) & 0x7F
        imm_4_0 = imm & 0x1F
        instruction = (imm_11_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_0 << 7) | opcode
        return f"{instruction:08X}"
    
    def encode_b_type(self, opcode: int, funct3: int, rs1: int, rs2: int, imm: int) -> str:
        imm_12 = (imm >> 12) & 0x1
        imm_10_5 = (imm >> 5) & 0x3F
        imm_4_1 = (imm >> 1) & 0xF
        imm_11 = (imm >> 11) & 0x1
        instruction = (imm_12 << 31) | (imm_10_5 << 25) | (rs2 << 20) | (rs1 << 15) | (funct3 << 12) | (imm_4_1 << 8) | (imm_11 << 7) | opcode
        return f"{instruction:08X}"

# Hex File Writer
def write_hex_file(instructions: List[str], filename: str):
    with open(filename, 'w') as f:
        for instruction in instructions:
            f.write(f"{instruction}\n")

def main():
    if len(sys.argv) != 2:
        print("Usage: python simplerisc.py <input_file.tj>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    
    # Check if file has .tj extension
    if not input_file.endswith('.tj'):
        print("Error: Input file must have .tj extension")
        print("Usage: python simplerisc.py <input_file.tj>")
        sys.exit(1)
    
    # Automatically generate output hex file name
    base_name = input_file.rsplit('.', 1)[0]  # Remove extension
    output_file = f"{base_name}.hex"
    
    try:
        with open(input_file, 'r') as f:
            source_code = f.read()
        
        # Tokenize
        lexer = Lexer(source_code)
        tokens = lexer.tokenize()
        
        # Parse
        parser = Parser(tokens)
        ast = parser.parse()
        
        # Generate code
        codegen = CodeGenerator()
        instructions = codegen.generate(ast)
        
        # Write hex file
        write_hex_file(instructions, output_file)
        
        print(f"Compilation completed successfully!")
        print(f"Generated {len(instructions)} instructions")
        print(f"Output: {output_file}")
        
    except FileNotFoundError:
        print(f"Error: Could not find file '{input_file}'")
        sys.exit(1)
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
