/*
Simple assembler for the multicycle processor implementation.
Produces a MIF file that can be used to initialize the memory.
In addition to the 10 instructions, it supports the org directive
and the db directive. It also supports labels. It assumes that
the width of memory/data/instructions is a single byte, but can
support any depth by means of the MEM_SIZE constant.

Change R.Willenberg - Oct 2012: Also produces a *.mem file for ModelSim simulation purposes
*/

#include <iostream>
#include <fstream>
#include <string>
#include <cstdlib>
#include <map>
#include <cstdio>
#include <vector>

using namespace std;

#define MEM_SIZE 256
#define NUM_KEYWORDS 16

typedef struct instruction
{
	int addr;
	int line_number;
	string keyword;
	string operands;
} instr;

bool isKeyword(string str)
{
	string keywords[NUM_KEYWORDS] = {"load", "store", "add", "sub", "nand", "ori",
						  "shift", "shiftl", "shiftr", "bz", "bnz", "bpz",
					 "org", "db", "stop", "nop"};

	for (int i = 0; i < NUM_KEYWORDS; i++)
	{
		if (str == keywords[i])
			return true;
	}

	return false;
}

bool isNumber(string str)
{
	for (unsigned int i = 0; i < str.length(); i++)
	{
		if (i == 0)
		{
			if ((str[i] < '0' || str[i] > '9') && str[0] != '-')
				return false;
		}
		else if (str[i] < '0' || str[i] > '9')
			return false;
	}

	return true;
}

bool isHex(string str)
{
	for (unsigned int i = 0; i < str.length(); i++)
	{
		str[i] = toupper(str[i]);
		if ( (str[i] < '0' || str[i] > '9') && (str[i] < 'A' || str[i] > 'F') )
			return false;
	}

	return true;
}

bool isBinary(string str)
{
	for (unsigned int i = 0; i < str.length(); i++)
	{
		if (str[i] != '0' && str[i] != '1')
			return false;
	}

	return true;
}

bool isOctal(string str)
{
	for (unsigned int i = 0; i < str.length(); i++)
	{
		if (str[i] < '0' || str[i] > '7')
			return false;
	}

	return true;
}

bool labelExists (map <string, int>& labels, string label)
{
	return (labels.find(label) != labels.end());
}

bool extractOperands (string ops, int& op1, int& op2, bool load_store = false)
{
	size_t comma_pos = ops.find_first_of(",");
	if (comma_pos == string::npos || comma_pos == 0 || comma_pos == ops.length()-1)
		return false;
	else
	{
		string sop1 = ops.substr(0,comma_pos);
		string sop2 = ops.substr(comma_pos+1);
		if (sop1 != "r0" && sop1 != "r1" && sop1 != "r2" && sop1 != "r3")
			return false;
		if (load_store)
		{
			if (sop2 != "(r0)" && sop2 != "(r1)" && sop2 != "(r2)" && sop2 != "(r3)")
				return false;
			else
				op2 = sop2[2] - '0';
		}
		else
		{
			if (sop2 != "r0" && sop2 != "r1" && sop2 != "r2" && sop2 != "r3")
				return false;
			else
				op2 = sop2[1] - '0';
		}

		op1 = sop1[1] - '0';
	}

	return true;
}

int processNumber(string str)
{
	int num;

	if (str[0] == '$' && str.length() > 1)
	{
		str = str.substr(1);
		if (!isHex(str))
			throw "parse error";

		num = strtol(str.c_str(), NULL, 16);
	}
	else if (str[0] == '0' && str.length() > 1)
	{
		str = str.substr(1);
		if (!isOctal(str))
			throw "parse error";

		num = strtol(str.c_str(), NULL, 8);
	}
	else if (str[0] == '%' && str.length() > 1)
	{
		str = str.substr(1);
		if (!isBinary(str))
			throw "parse error";

		num = strtol(str.c_str(), NULL, 2);
	}
	else 
	{
		if (!isNumber(str))
			throw "parse error";

		num = atoi(str.c_str());
	}

	return num;
}

int main(int argc, char* argv[])
{
	string line = " ";
	char outfilename[1024];
	char mem[MEM_SIZE];
	int line_count = 0;
	unsigned int cur_address = 0;
	map <string, int> labels;
	vector <instr> instructions;
	

	if (argc < 2 || argc > 3)
	{
		cerr << "Usage: asm assembly_file [mif_file]" << endl;
		exit(1);
	}

	ifstream infile(argv[1], ios::in);

	if (infile.fail())
	{
		cerr << "Error: cannot open the input file.";
		exit(1);
	}

	ofstream outfile;	
	ofstream outfilesim;	

	if (argc == 2)
		strcpy(outfilename,"data.mif");
	else if (argc == 3)
		strcpy(outfilename,argv[2]);
	
	outfile.open(outfilename, ios::out);

	if (outfile.fail())
	{
		cerr << "Error: cannot open the output file.";
		exit(1);
	}

	strcat(outfilename,".mem");
	
	outfilesim.open(outfilename, ios::out);

	if (outfilesim.fail())
	{
		cerr << "Error: cannot open the simulation mem file.";
		outfile.close();
		exit(1);
	}

	// init memory to all zeros
	for (int i = 0; i < MEM_SIZE; i++)
		mem[i] = 0;

	while (!infile.eof())
	{
		getline(infile, line);
		if (line.length() > 0 && line[line.length()-1] == '\r')
			line.resize(line.length() - 1);
		string col1, col2, col3;
		size_t b, e;

		line_count++;

		try
		{
			// is line empty or is it a comment?
			b = line.find_first_not_of(" \t", 0);
			if (b == string::npos || line[b] == ';')
				continue;

			if (line[0] == ' ' || line[0] == '\t')
			{
				col1 = "";
			}
			else
			{
				e = line.find_first_of(" \t", 0);
				b = line.find_first_not_of(" \t", e);
			
				if (e == string::npos || b == string::npos)
					throw "parse error";
			
				col1 = line.substr(0, e);
			}

			e = line.find_first_of(" \t", b);

			if (e == string::npos) {
			  col2 = line.substr(b);
			  if (col2 != "stop" && col2 != "nop")
			    throw "parse error";
			  
			}
			else col2 = line.substr(b, e-b);

			if (col2 != "stop" && col2 != "nop") 
			  {
			    b = line.find_first_not_of(" \t", e);
			
			    if (e == string::npos)
			      throw "parse error";

			    e = line.find_first_of(" \t;", b);

			    if (e == string::npos)
			      col3 = line.substr(b);
			    else 
			      {
				if (line[e] != ';')
				  {
				    size_t tmp_pos = line.find_first_not_of(" \t", e);
				    if (tmp_pos != string::npos && line[tmp_pos] != ';')
				      throw "parse error";
				  }

				col3 = line.substr(b, e-b);
			      }
			  }
			if (!isKeyword(col2))
			{
				cerr << "Error: line " << line_count << ", unrecognized term '" << col2 << "'." << endl;
				exit(1);
			}

			if (col2 == "org")
			{	
				int addr = (unsigned int) processNumber(col3);

				if (addr < 0 || addr > MEM_SIZE - 1)
				{
					cerr << "Error: line " << line_count << ", address out of range." << endl;
					exit(1);
				}
				
				cur_address = addr;

				if (col1 != "")
				{
					if (labelExists(labels, col1))
					{
						cerr << "Error: line " << line_count << ", duplicate declaration of '" << col1 << "'." << endl;
						exit(1);
					}
					else
						labels[col1] = cur_address;
				}
				continue;
			}

			if (col1 != "")
			{
				if (labelExists(labels, col1))
				{
					cerr << "Error: line " << line_count << ", duplicate declaration of '" << col1 << "'." << endl;
					exit(1);
				}
				else
					labels[col1] = cur_address;
			}

			instr op;
			op.addr = cur_address;
			op.line_number = line_count;
			op.keyword = col2;
			op.operands = col3;
			instructions.push_back(op);

			cur_address++;
		}
		catch (...)
		{
			cerr << "Error: line " << line_count << "." << endl;
			exit(1);
		}
	}

	infile.close();

	for (unsigned int i = 0; i < instructions.size(); i++)
	{
		try
		{
			cur_address = instructions[i].addr;
			line_count = instructions[i].line_number;
			string col2 = instructions[i].keyword;
			string col3 = instructions[i].operands;

			if (cur_address > MEM_SIZE - 1)
			{
				cerr << "Error: line " << line_count << ", location of data or instruction overruns maximum address space." << endl;
				exit(1);
			}

			int op1, op2;
			int encoding;

			if (col2 == "db")
			{
				char c_encoding;
				// single character?
				if (col3.length() == 3 && col3[0] == '\'' && col3[2] == '\'')
					c_encoding = col3[1];
				else
				{
					c_encoding = (char) processNumber(col3);
					if (c_encoding < -128 || c_encoding > 127)
					{
						cerr << "Error: line " << line_count << ", invalid argument to 'db'." << endl;
						exit(1);
					}
				}
				encoding = (int) c_encoding;
			}
			else if (col2 == "load")
			{
				if (!extractOperands(col3, op1, op2, true))
					throw "parse error";
				
				encoding = 0;
				encoding = op1 << 6;
				encoding += op2 << 4;
			}
			else if (col2 == "store")
			{
				if (!extractOperands(col3, op1, op2, true))
					throw "parse error";
				
				encoding = 0;
				encoding = op1 << 6;
				encoding += op2 << 4;
				encoding |= 2;
			}
			else if (col2 == "add")
			{
				if (!extractOperands(col3, op1, op2))
					throw "parse error";
				
				encoding = 0;
				encoding = op1 << 6;
				encoding += op2 << 4;
				encoding |= 4;
			}
			else if (col2 == "sub")
			{
				if (!extractOperands(col3, op1, op2))
					throw "parse error";
				
				encoding = 0;
				encoding = op1 << 6;
				encoding += op2 << 4;
				encoding |= 6;
			}
			else if (col2 == "nand")
			{
				if (!extractOperands(col3, op1, op2))
					throw "parse error";
				
				encoding = 0;
				encoding = op1 << 6;
				encoding += op2 << 4;
				encoding |= 8;
			}
			else if (col2 == "ori")
			{
				unsigned int imm5 = (unsigned int) processNumber(col3);
				
				if (imm5 < 0 || imm5 > 31)
				{
					cerr << "Error: line " << line_count << ", number too large to fit in 5 bits (or is negative)." << endl;
					exit(1);
				}

				encoding = imm5;
				encoding <<= 3;
				encoding |= 7;
			}
			else if (col2 == "shift" || col2 == "shiftl" || col2 == "shiftr")
			{
				size_t comma_pos = col3.find_first_of(",");
				if (comma_pos == string::npos || comma_pos == 0 || comma_pos == col3.length()-1)
					throw "parse error";
				else
				{
					string sop1 = col3.substr(0,comma_pos);
					string sop2 = col3.substr(comma_pos+1);
					if (sop1 != "r0" && sop1 != "r1" && sop1 != "r2" && sop1 != "r3")
						throw "parse error";

					unsigned int imm3 = (unsigned int) processNumber(sop2);
					
					if (col2 == "shiftl" || col2 == "shiftr")
					{
						if (imm3 > 3)
						{
							cerr << "Error: line " << line_count << ", shiftl and shiftr can only accept parameters between 0 and 3." << endl;
							exit(1);
						}

						if (col2 == "shiftl")
							imm3 |= 4;
					}	
					else if (imm3 < 0 || imm3 > 7)
					{
						cerr << "Error: line " << line_count << ", number too large to fit in 3 bits (or is negative)." << endl;
						exit(1);
					}

					encoding = 0;
					encoding = (sop1[1] - '0') << 6;
					encoding += imm3 << 3;
					encoding |= 3;
				}
			}
			else if (col2 == "bz" || col2 == "bnz" || col2 == "bpz")
			{
				int imm4;
				if (labelExists(labels, col3))
				{
					int lbl_address = labels[col3];
					imm4 = (lbl_address - cur_address) - 1;
				}
				else
					imm4 = processNumber(col3);
				
				if (imm4 < -8 || imm4 > 7)
				{
					cerr << "Error: line " << line_count << ", number cannot fit in 4 bits." << endl;
					exit(1);
				}

				encoding = imm4;
				encoding <<= 4;

				if (col2 == "bz")
					encoding |= 5;
				else if (col2 == "bnz")
					encoding |= 9;
				else
					encoding |= 13;
			}
			else if (col2 == "stop")
			  {
			    encoding = 1;
			  }
			else if (col2 == "nop")
			  {
			    encoding = 10;
			  }
			
			mem[cur_address] = (char) encoding;
		}
		catch (...)
		{
			cerr << "Error: line " << line_count << "." << endl;
			exit(1);
		}
	}

	// write output file
	outfile << "DEPTH = " << MEM_SIZE << ";" << endl;
	outfile << "WIDTH = 8;" << endl;
	outfile << "ADDRESS_RADIX = HEX;" << endl;
	outfile << "DATA_RADIX = HEX;" << endl;
	outfile << "CONTENT" << endl;
	outfile << "BEGIN" << endl << endl;

	for (int i = 0; i < MEM_SIZE; i++)
	{
		char str[10];
		sprintf(str, "%2.2hX", i);
		outfile << str << " : ";

		sprintf(str, "%2.2hX", mem[i]);
		if (strlen(str) > 2)
		{
			str[0] = str[2];
			str[1] = str[3];
			str[2] = '\0';
		}

		outfile << str << ";" << endl;
	}

	outfile << endl << "END;" << endl;

	outfile.close();

	// write simulation memory file
	outfilesim << "// memory data file (do not edit the following line - required for mem load use)" << endl;
	outfilesim << "// instance=/multicycle/DataMem/b2v_inst/altsyncram_component/mem_data" << endl;
	outfilesim << "// format=mti addressradix=h dataradix=h version=1.0 wordsperline=1" << endl;
	
	for (int i = 0; i < MEM_SIZE; i++)
	{
		char str[10];
		sprintf(str, "%2.2hx", i);
		outfilesim << str << ": ";

		sprintf(str, "%2.2hx", mem[i]);
		if (strlen(str) > 2)
		{
			str[0] = str[2];
			str[1] = str[3];
			str[2] = '\0';
		}

		outfilesim << str << endl;
	}

	outfilesim.close();
	
	return 0;
}
