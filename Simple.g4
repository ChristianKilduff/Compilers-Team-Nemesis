grammar Simple;
// -------- Parser Members: global state for simple semantic checks --------
@header { import java.util.*; import java.io.*;}

@members {
  boolean isDebug = true;

  class Types {
    final static String STRING = "String";
    final static String INT = "int";
    final static String DOUBLE = "double";
    final static String ARRAY= "array";
    final static String BOOL = "boolean";
    final static String FUNCTION_CALL = "function call";
    final static String VARIABLE = "variable";
    final static String UNKNOWN = "unknown";
  }

  /** Identifier type */
  class Identifier {
    String id;
    String value;  // The value of this identifier
    String type = Types.UNKNOWN;
    String arrayType;
    boolean hasKnown; // Is the value known or not
    boolean hasBeenUsed;  // Has the id been used yet
    String scope; // function/global scope
    int scopeLevel;
  }

  class FunctionIdentifier {
    String name;
    int arity;
    ArrayList<String> paramTypes;
    ArrayList<String> paramNames;
    boolean doesReturn;
    String returnType;
    String block_name;
    ArrayList<String> code = new ArrayList<String>();

    void addLine(String line) {
      code.add(line);
    }

    String getParamRef(int index) {
      return "____PARAM____" + name + "_____" + index;
    }

    void assignOrReassign(int index, String value) {
      generateAssignOrReassign(getParamRef(index), value, paramTypes.get(index));
    }
  }

  void addCodeLine(String line) {
    if(isScopeGlobal()) {
	      globalCodeLines.add(line);
    } else {
        addToCodeBlock(getScope(), line);
    }
  }


  int strIteration = 0;
  void addPrintLine(String line) {
    String ref = "\tpstr" + strIteration;
	      strIteration++;

	    String assignStr = ".data\n"
      + ref+": .asciz \""
        + line
        + "\"\n\t"
        + ".text";

		  String printStr = "\tla    a0, "+ref
	      + "\n\tli    a7, 4"
        +"\n\tecall";
	      addCodeLine(assignStr + "\n" + printStr + "\n");
  }

  void addPrintNewLine() {
		      addCodeLine("jal ra, print_newline");
  }

  
	ArrayList<String> globalCodeLines = new ArrayList<String>();
  Map<String, ArrayList<String>> codeBlockLines = new HashMap();

  Map<String, FunctionIdentifier> functionTable = new HashMap();
  ArrayList<FunctionIdentifier> functionList = new ArrayList<FunctionIdentifier>();
  FunctionIdentifier getFunction(String name) {
    return functionTable.get(name);
  }

  FunctionIdentifier createFunction(String name, int arity, boolean doesReturn, String returnType, ArrayList<String> paramTypes, ArrayList<String> paramNames) {
    FunctionIdentifier fid = new FunctionIdentifier();
    fid.name = name;
    fid.arity = arity;
    fid.doesReturn = doesReturn;
    fid.returnType = returnType;
    fid.paramTypes = paramTypes;
    fid.paramNames = paramNames;

    for(int i = 0; i < arity; i++) {
      globalVariables.add(createGlobalScopeVariable(fid.getParamRef(i), "0", paramTypes.get(i)));
    }

    fid.block_name = "____FUNCTION___" + name;
    functionTable.put(name, fid);
    if(isDebug)
      System.out.println("Created func: name: " + name + " | arity: " + arity + " | doesReturn: " + doesReturn);
    return fid;
  }

  boolean doesFunctionExist(String name) {
    return getFunction(name) != null;
  }



// matches the name of a variable to the identifier
  class SymbolTable extends HashMap<String, Identifier> {
  }



// tracks variables by scope level, key is global/function name, arraylist is level of scope for loops/ifs
  class ScopedSymbolTable extends HashMap<String, ArrayList<SymbolTable>> {
	    ScopedSymbolTable() {
        ArrayList<SymbolTable> l = new ArrayList<SymbolTable>();
        l.add(new SymbolTable());
        this.put("Global", l);
      }
  }

  void addToCodeBlock(String name, String code) {
    if(codeBlockLines.get(name) == null) codeBlockLines.put(name, new ArrayList<String>());

	  codeBlockLines.get(name).add(code);
  }

  int isFunctionReturning = 0;

	ScopedSymbolTable scopedSymbolTable = new ScopedSymbolTable();
  int scopeLevel = 0;
  String currScope = "Global";
  

  void setScope(String name) {
	    currScope = name;
	    scopedSymbolTable.put(name, new ArrayList<SymbolTable>());
  }

  void exitMainScope() {
    currScope = "Global";
  }

  boolean isScopeGlobal() {
    return currScope.equals("Global");
  }

  String getScope() {
    return currScope;
  }

  int getScopeLevel() {
		    ArrayList<SymbolTable> tables = scopedSymbolTable.get(getScope());
      if(tables.size() == 0) {
        return addScopeLevel();
      }
      return tables.size();
  }

  int addScopeLevel() {
	    ArrayList<SymbolTable> tables = scopedSymbolTable.get(getScope());
      tables.add(new SymbolTable());
      return tables.size();
  }

  void removeScopeLevel() {
    ArrayList<SymbolTable> tables = scopedSymbolTable.get(getScope());
    if(tables.size() > 0) {
      tables.remove(tables.size()-1);
    }
  }

  

  SymbolTable getCurrSymbolTableAtCurrLevel() {
      return scopedSymbolTable.get("Global").get(0);
	    // ArrayList<SymbolTable> tables = scopedSymbolTable.get(getScope());
      // if(tables.size() == 0) {
      //   tables.add(new SymbolTable());
      // }
      // return tables.get(tables.size() - 1);
  }

  Identifier createVariable(String name, String value, String type) {
    // if variable already exists in global or curr scope then cannot assign; return null
    if(getVariable(name) != null) {
      return null;
    }
    Identifier id = new Identifier();
    id.id = name;
    id.value = value;
    id.type = type;
    id.scope = currScope;
    id.scopeLevel = getScopeLevel();
	  getCurrSymbolTableAtCurrLevel().put(name, id);

    return id;
  }

	  Identifier createGlobalScopeVariable(String name, String value, String type) {
    // if variable already exists in global or curr scope then cannot assign; return null
    if(getVariable(name) != null) {
      return null;
    }
    Identifier id = new Identifier();
    id.id = name;
    id.value = value;
    id.type = type;
    id.scope = "Global";
    id.scopeLevel = 0;
	  getCurrSymbolTableAtCurrLevel().put(name, id);

    return id;
  }


  Identifier getVariable(String name) {
    String[] scopes;
    if (isScopeGlobal()) {
      scopes = new String[] {"Global"};
    } else {
      scopes = new String[] {"Global", getScope()};
    }

	    for (String key : scopes) {
	        ArrayList<SymbolTable> tables = scopedSymbolTable.get(key);
          for(SymbolTable table : tables) {
            for(String varName : table.keySet()) {
                if(varName.equals(name)) {
                  return table.get(varName);
                }
            }
          }
	          
      }
      return null;
  }


  Map<String, RiscArray> ARRAYS = new HashMap();

  RiscArray generateArray(String name, String type, String ... values) {
      RiscArray arr  = new RiscArray(name, type);
      ARRAYS.put(name, arr);
      for(String v : values) {
        arr.add(v, false);
      }

      return arr;
  }

  int array_count = 0;
  class RiscArray {
    String name;
    int c = array_count++;
    int i = 0;
    String type;
    String sizeVarName;

    public RiscArray(String name, String type) {
      this.name = name;
      this.type = type;
	      i=array_count++;
        sizeVarName = "count_arr_"+i;
        
        int size = 400;
        if(type.equals(Types.DOUBLE)) size *=2;
	      addCodeLine(".data"
          + "\n\t" + name + ": .space 400"
          + "\n\t" + sizeVarName +":   .word 0"
          + "\n\t.text\n");
    }


    void add(String value, boolean isVar) {     

	      String code = "\n\t#====\n\t" +
        "la t0, " + sizeVarName // t0 = size address
        + "\n\tlw t1, 0(t0)"; // t1 = curr size

        int mul = type.equals(Types.DOUBLE) ? 3 : 2;
        code += "\n\tla t2, " + name  // t2 = array address
        + "\n\tslli t3, t1, " + mul // t3 = t1 * 4 (get the position of next avail slot)
        + "\n\tadd t3, t2, t3"; //t3 = address of arr[i]

       
       if(isVar) {
        code += "\n\tla t4, " + value; // t4 = address of value
        if(type.equals(Types.DOUBLE))
          code += "\n\tfld fa0, (t4)";
        else 
          code += "\n\tlw t4, (t4)"; // t4 = value

       } else {
        if (type.equals(Types.DOUBLE)) {
          String tmpDoubleName = "double____" + data_count++;
          code += "\n\t.data\n\t" + tmpDoubleName + ": .double " + value + "\n\t.text";
          code += "\n\tla t4, " + tmpDoubleName ;// t4 = tmp address
          code += "\n\tfld fa0, 0(t4)";
        } else {
	        code += "\n\tli t4, " + value; // t4 = value to add
        }
       }

       if(type.equals(Types.DOUBLE))
        code+= "\n\tfsd fa0, 0(t3)";  // store into arr
       else
        code+= "\n\tsw t4, 0(t3)";  // store into arr

        code += "\n\taddi t1, t1, 1" // incr count
        + "\n\tla t0, " + sizeVarName // t0 = count address
        + "\n\tsw t1, 0(t0)"; // update count
        
        code += "\n\t#_____\n\t";

        addCodeLine(code);
      
    }

    void assignSize(String varName) {
	      assignVarToVar(varName, sizeVarName, Types.INT);
    }
    
    void set(int index, String value, boolean isIndexVar, boolean isValueVar) {
      
        String code = "";

        if(isIndexVar) {
          code+="la t0, " + index // t0 = size address
        + "\n\tlw t1, (t0)" // t1 = index
        + "\n\taddi t1, -1"; // t1 - 1
        } else {
          code+="li t1, " + index;
        }

        code += "\n\tla t2, " + name  // t2 = array address
        + "\n\tslli t3, t1, 2" // t3 = t1 * 4 (get the position of next avail slot)
        + "\n\tadd t3, t2, t3"; //t3 = address of arr[i]

       
        code += "\n\tlw t4, " + value // t4 = value to add
        + "\n\tsw t4, 0(t3)";  // store into arr


        addCodeLine(code);
    }


    void remove(int index) {
      
    }

    void clear() {
      // just set size to 0
      String code = "\n\tli t1, 0" // incr count
      + "\n\tla t0, " + sizeVarName // t0 = count address
      + "\n\tsw t1, 0(t0)"; // update count
      addCodeLine(code);
    }

    // all ai
    void print() {
	      int c = data_count++;
        String loop_name = "loop_" + c;
        String done_name = "done_" + c;
        String code = 
            "\n\tla t0, " + name + "\n\t" // arr address (t0)
            + "lw t1, " + sizeVarName  + "\n\t" // size of array (t1)
            + "li t2, 0 \n\t" // index (t2)
            + "\n\t"
	            + loop_name +":\n\t"
            + "bge t2, t1, " + done_name +"\n\t"; // loop while index < count

        if (type.equals(Types.DOUBLE)) {
            // For double
            code += 
                "slli t3, t2, 3    # t3 = index * 8 (double size)\n\t" +
                "add t3, t0, t3    # t3 = address of name[index]\n\t" +
                "fld fa0, 0(t3)    # load double into fa0\n\t" +
                "li a7, 3\n\t" +   // RARS syscall 2 = print double
                "ecall\n\t";
        } else {
            // For .word (integer)
            code += 
                "slli t3, t2, 2    # t3 = index * 4 (word size)\n\t" +
                "add t3, t0, t3    # t3 = address of arr[index]\n\t" +
                "lw a0, 0(t3)      # load integer into a0\n\t" +
                "li a7, 1\n\t" +   // RARS syscall 1 = print integer
                "ecall\n\t";
        }
        code += "\n\tla t5, space"  
              + "\n\tlw a0, (t5)"
              + "\n\tli a7, 4"     
              + "\n\tecall\n\t";
        // Increment index and loop
        code += 
            "addi t2, t2, 1\n\t" +
            "j " + loop_name+ "\n\t" +
            "\n\t"
            + done_name +":\n\t";

        addCodeLine(code);
    }


  }

  boolean doesVariableExist(String varName) {
    return getVariable(varName) != null;
  }


  /** Variables that appear in any expression or print (i.e., used). */
  Set<String> used = new HashSet<>();

  /** Collected diagnostics we’ll print at the end. */
  List<String> diagnostics = new ArrayList<>();


  /** Helper to record an error with source coordinates. */
  void error(Token t, String msg) {
    diagnostics.add("line " + t.getLine() + ":" + t.getCharPositionInLine() + " " + msg);
  }

  int printDiagnostics() {
    boolean printOnce=true;
      int numErrors = 0;
      // After parsing the whole file: report unused variables and print errors.
      for (String d : diagnostics) {
        if(isDebug && printOnce) {
          System.out.println("\n––––––– Errors –––––––\n");
          printOnce=false;
        }
        System.err.println("error: " + d);
        numErrors++;
      }
      return numErrors;
  }
  //Code generation
  StringBuilder sb = new StringBuilder();
  //StringBuilder dataSb = new StringBuilder();
  StringBuilder sb2 = new StringBuilder();
  int data_count = 0;
  String CONST_PREFIX = "VAL";
  

  void generateDoubleAssign(String name, String value) {
	    if(value == null) value = "0";
    String s = ".data"
    +"\n\t" + name  + ": .double "+value
    +"\n\t.text";
    addCodeLine(s);
  }


  void reassignDouble(String name, String value) {
    if(value == null) value = "0";
	    String dName="DOUBLE_" + data_count;
      data_count++;
      String new_double = ".data"
      + "\n\t" + dName + ": .double " + value
      +"\n\t.text";

      addCodeLine(new_double);

	
    addCodeLine("la t0," + dName);
    addCodeLine("fld  fa0, (t0)");
    addCodeLine("la t0, " + name);
    addCodeLine("fsd fa0, (t0)");
    addCodeLine("la t0, " + name);
    addCodeLine("fld fa0, (t0)");
  }

  void generateAssignOrReassign(String name, String value, String type) {
		    if(type.equals(Types.DOUBLE)) {
          if(doesVariableExist(name))
            reassignDouble(name, value);
          else
            generateDoubleAssign(name, value);
        } 
        else if(type.equals(Types.INT)) {
	        if(doesVariableExist(name))
            reassignInt(name, value);
          else
            generateIntAssign(name, value);
        } else if(type.equals(Types.STRING)) {
	        if(doesVariableExist(name))
            reassignString(name, value);
          else
            generateStringAssign(name, value);
        } 
  }

	  void generateInitialAssign(String name, String value, String type) {
		    if(type.equals(Types.DOUBLE)) {
            generateDoubleAssign(name, value);
        } 
        else if(type.equals(Types.INT)) {
            generateIntAssign(name, value);
        } else if(type.equals(Types.STRING)) {
            generateStringAssign(name, value);
        } 
  }

  void generateReassign(String name, String value, String type) {
      if(type.equals(Types.DOUBLE)) {
        reassignDouble(name, value);
      }
      else if(type.equals(Types.INT)) {
            String reAssignCode = "li t0, " + value
            +"\n\tla t1, " + name
            +"\n\tsw t0, 0(t1)";

            addCodeLine(reAssignCode);
      } else if(type.equals(Types.STRING)) {
        reassignString(name, value);
      } 
  }


  void generateIntAssign(String name, String value) {
    String s = ".data\n"
      + "\t" + name + ": .word " + value
      +"\n\t.text";
    addCodeLine(s);
  }
  void reassignInt(String varName, String value) {
    // set t0 to the value wanted
    addCodeLine("li t0, " + value);
    // t1 = address of var
    addCodeLine("la t1, " + varName);
    addCodeLine("sw t0 0(t1)");
  }


  void generateStringAssign(String name, String value) {
    String tmpN = name + "_tmp____protected";
    String s = ".data" 
      + "\n\t" + tmpN + ": .asciz " + "\"" + value + "\""
      + "\n\t" + name + ": .word " + tmpN
	    +"\n\t.text";
    addCodeLine(s);
  }

  void reassignString(String name, String value) {
    data_count++;
    String tmpName = "tmpStr_" + data_count;
    String s = ".data" 
	    +"\n\t" + tmpName +": .asciz " + value +""
	    +"\n\t.text";

    addCodeLine(s);
    data_count++;

	

    addCodeLine("la t0," + name);
    addCodeLine("la t1, " + tmpName);
    addCodeLine("sw t1, (t0)");
  }

  String generateLoadId (String id) {
    String code = "";
    code += "la t0, " + id + "\n";
    code += "    fld " + "ft0" + ",(t0)" + "\n";
    return code;
  }

  void emit(String s) {sb.append(s);}  
  //File generation
  void openProgram() {
    emit(".text"
    + "\n.globl main"
    + "\n.globl end"
    + "\n.globl print_newline\n\n");
    emit("main:\n");
  }

  void writeFile() {
    try (PrintWriter pw = new PrintWriter("SimpleProgram.S", "UTF-8")) {
      setScope("globalVars");
      generateInitialAssign("space", " ", Types.STRING);
      for(Identifier var : globalVariables) {
        generateInitialAssign(var.id, "0", var.type);
      }
      exitMainScope();

      ArrayList<String> vars = codeBlockLines.get("globalVars");
      if(vars != null)
        for(String line : vars) 
              pw.print("\t"+line + "\n");

      codeBlockLines.remove("globalVars");


      for(int i=0; i<functionList.size(); i++) {
        FunctionIdentifier fid = functionList.get(i);
        for(String line : fid.code) {
          sb.append(line + "\n");
        }
      }
      pw.print(sb.toString());
      for(String line : globalCodeLines) {
          sb2.append("\t"+line + "\n");
      } 
      pw.print(sb2.toString());

      

	      pw.print(
	    "\tjal end\n");

      for(String key : codeBlockLines.keySet()) {
	          pw.print(getFunctionInitCode(key));
          for(String line : codeBlockLines.get(key)) {
            pw.print("\t"+line + "\n");
        } 
      }

      pw.print("\nprint_newline:");

	    pw.print("\n\taddi sp, sp, -8"
        + "\n\tsw ra, 4(sp)     # save return address"
        + "\n\tsw a0, 0(sp)     # save n");
     
      pw.print(
	    "\n\tli    a0, '\\n'"
		    + "\n\tli    a7, 11"
		    + "\n\tecall");

      pw.print("\n\tlw ra, 4(sp)       # restore ra"
        + "\n\tlw a0, 0(sp)"
        + "\n\taddi sp, sp, 8"
		    + "\n\tret");

		    pw.print("\nend:\n"
        + "\t# print new line\n"
        +"\tjal ra, print_newline\n"
		    + "\n\tli    a0, 0     # Load the exit code (e.g., 0 for success) into a0"
		    + "\n\tli    a7, 93    # Load the Exit2 syscall number into a7"
		    + "\n\tecall        # Execute the system call to exit"
    );
    } catch (Exception e) {
      e.printStackTrace();
      System.err.println("error: failed to write SimpleProgram: " + e.getMessage());
    }

  }//}


	  int loop_index = 0;
    void enterLoop(String block_name, String return_name) {
      loopBlocks.push(block_name);
      loopReturnBlocks.push(return_name);
    }

    String getCurrLoopReturn() {
	      return loopReturnBlocks.peek();
    }

    String finishLoop() {
      loopBlocks.pop();
	    return loopReturnBlocks.pop();
    }

    void addLoopCall() {
      addCodeLine("j " + loopBlocks.peek());
    }

    boolean isInLoop() {
      return !loopReturnBlocks.isEmpty();
    }

    String getLoop() {
	      return loopBlocks.peek();
    }

    String getLoopReturn() {
        return loopReturnBlocks.peek();
    }


  void genConditionalCode(String left, String right, String leftType, String rightType, String risc_word, String ifBlock) {
    Map<String,String> leftMap = genConditionalCodeHelper(left, leftType, 0);
    Map<String,String> rightMap = genConditionalCodeHelper(right, rightType, 1);

    String code = rightMap.get("conditional_code");
    code = code.replace("<risc>", risc_word);
    code = code.replace("<branch>", ifBlock);
    code = code.replace("<left_register>", leftMap.get("register"));
    code = code.replace("<right_register>", rightMap.get("register"));
    addCodeLine(code);

  }

Map<String,String> genConditionalCodeHelper(String a, String type, int i) {
  Map<String,String> outmap = new HashMap();
  String addressRegister = "t" + i;
  String valueRegister = addressRegister;
  System.out.println(type);
  if(type.equals(Types.VARIABLE)) {
    Identifier var = getVariable(a);
      addCodeLine("la "+ addressRegister+ ", " + a);
    if(var.type.equals(Types.INT)) {
      addCodeLine("lw " + valueRegister + ", (" + addressRegister + ")");
      outmap.put("conditional_code", "b<risc> <left_register>, <right_register>, <branch>");
    } else if(var.type.equals(Types.DOUBLE)) {
      valueRegister = "fa" + i;
      addCodeLine("fld " + valueRegister + ", (" + addressRegister + ")");
      outmap.put("conditional_code", "f<risc>.d t2, <left_register>, <right_register>" + "\n\tbnez t2, <branch>");
    }
  } else if(type.equals(Types.DOUBLE)) {
    data_count++;
    valueRegister = "fa" + i;

    String tmpVarName = "tmp_d_______" + data_count;
    addCodeLine(".data\n\t"+tmpVarName+": .double " + a +"\n\t.text");
    addCodeLine("la t0, " + tmpVarName);
	  addCodeLine("fld " + valueRegister + ", (t0)");

    outmap.put("conditional_code", "f<risc>.d t2, fa0, fa1" + "\n\tbnez t2, <branch>");

  } else if(type.equals(Types.INT)) {
    outmap.put("conditional_code", "b<risc> <left_register>, <right_register>, <branch>");
    addCodeLine("li "+ valueRegister+ ", " + a);
  }
  
  outmap.put("register", valueRegister);
  return outmap;

}


	int condition_index = 0;

  Stack<String> loopBlocks = new Stack<String>();
  Stack<String> loopReturnBlocks = new Stack<String>();

  void call(String name) {
    addCodeLine("jal ra, " + name);
  }


  void printVar(String name, String type) {

        if(type.equals(Types.INT)) {
              String loadStr = "la t1, " + name
              +"\n\tlw t2, 0(t1)";

              String printIntStr= "addi a0, t2, 0"
              +"\n\tli    a7, 1"
              +"\n\tecall";

              addCodeLine(loadStr);
              addCodeLine(printIntStr);
          } else if(type.equals(Types.DOUBLE)) {
            String printDouble = "la t0, " + name
            + "\n\tfld fa0, (t0)"
            + "\n\tli a7, 3"
            + "\n\tecall";

            addCodeLine(printDouble);
          } else if(type.equals(Types.STRING)) {
            addCodeLine("lw a0, " + name);
            
            String printStr = "li a7, 4"
            + "\n\tecall";

            addCodeLine(printStr);
          } else if(type.equals(Types.ARRAY)) {
            RiscArray arr = ARRAYS.get(name);
            if(arr != null) {
              arr.print();
            }
          }
  }
	  String getAssignVarToVar(String toAssign, String assignFrom, String type) {
      String code = "\n";
      if(type.equals(Types.INT) | type.equals(Types.STRING)) {
        code += "la t0, " + assignFrom 
        + "\n\tlw t1 (t0)" 
        + "\n\tla t2, " + toAssign 
        + "\n\tsw t1 (t2)\n";
      } else if(type.equals(Types.DOUBLE)) {
        code += "la t0, " + assignFrom 
        + "\n\tfld fa0 (t0)" 
        + "\n\tla t2, " + toAssign 
        + "\n\tfsd fa0 (t2)\n";
      }

      return code;
  }
  void assignVarToVar(String toAssign, String assignFrom, String type) {
    String code = "";
    if(type.equals(Types.INT) | type.equals(Types.STRING)) {
      code = "la t0, " + assignFrom 
      + "\n\tlw t1 (t0)" 
      + "\n\tla t2, " + toAssign 
      + "\n\tsw t1 (t2)";
    } else if(type.equals(Types.DOUBLE)) {
	    code = "la t0, " + assignFrom 
      + "\n\tfld fa0 (t0)" 
      + "\n\tla t2, " + toAssign 
      + "\n\tfsd fa0 (t2)";
    }

    addCodeLine(code);
  }

  String upRa() {
	    return "\n\taddi sp, sp, -8"
    + "\n\tsw ra, 4(sp)     # save return address"
    + "\n\tsw a0, 0(sp)\n";
  }

  String downRa() {
    return "lw ra, 4(sp) # restore ra"
    + "\n\tlw a0, 0(sp)"
    + "\n\taddi sp, sp, 8";
  }
  String getFunctionInitCode(String fName) {
    FunctionIdentifier fid = getFunction(fName);
    // block and return address code
    String code = fid.block_name + ":" + upRa();

    // set params
    for(int i = 0; i < fid.arity; i++) {
      String var_name = fid.paramNames.get(i);
      String param_name = fid.getParamRef(i);

      code+="\n\t" + getAssignVarToVar(var_name, param_name, fid.paramTypes.get(i));
    }


    return code;
  }


  void addReturnVoidCall() {
	  addCodeLine(downRa());

    addCodeLine("ret");
  }

  ArrayList<Identifier> globalVariables = new ArrayList<Identifier>();


  int clone_count = 0;


  void addDoubleVars(String var, String f1, String f2) {
    addCodeLine("la t2, " + var);
    addCodeLine("la t0, " + f1);
    addCodeLine("la t1, " + f2);

    addCodeLine("\n\tfld fa0, 0(t0)");
    addCodeLine("fld fa1, 0(t1)");

    addCodeLine("fadd.d fa2, fa0, fa1");
    addCodeLine("fsd fa2, (t2)");
  }
  void multiplyDoubleVars(String var, String f1, String f2) {
    addCodeLine("la t2, " + var);
    addCodeLine("la t0, " + f1);
    addCodeLine("la t1, " + f2);

    addCodeLine("\n\tfld fa0, 0(t0)");
    addCodeLine("fld fa1, 0(t1)");

    addCodeLine("fmul.d fa2, fa0, fa1");
    addCodeLine("fsd fa2, (t2)");
  }
}

prog:
	{
    openProgram();
    // True : print debug messages like variable assigning and function creation/calls
    // False : Don't. Just prints the errors and whether it compiled successfully or not
    isDebug = false;
    } (statement | functionDefinition)* {
	     int numErrors = printDiagnostics();
       if(numErrors == 0) {
        if(isDebug) System.out.println("\n––");
        System.out.println("Compile Successful");
        writeFile();
       } else {
        System.err.println("There are errors in the program, cannot compile");
        System.exit(1);
       }
	  };

assignment
	locals[String value, String typeOf, boolean isError, boolean isVar, boolean isExpr]:
	name = VARIABLE_NAME '=' (
		t = DECIMAL {
      $typeOf = Types.DOUBLE;
	    $value = $t.getText();
    }
		| t = INT {
      $typeOf = Types.INT;
	    $value = $t.getText();
    }
		| t = STRING {
      $typeOf = Types.STRING;
	    $value = $t.getText();
    }
		| t = BOOL {
      $typeOf = Types.BOOL;
      $value = $t.getText().toLowerCase();
    }
		| a = array {
      $typeOf=Types.ARRAY;
      $value="[]";
    }
		| v = VARIABLE_NAME {
	      Identifier var = getVariable($v.getText());
      if(var == null) {
          error($v, "Error variable " + $v.getText() + " does not exist");
          $isError = true;
      } else if (var.scope != "Global" && var.scope != getScope()) {
          error($v, "Error attempting to assign a variable that is not defined (there is a variable defined that is out of scope)");
          $isError = true;
      } else {
        $value = var.value;    
        $typeOf = var.type;
        $isVar = true;
      }
    }
		| e = expr {
	    if(isDebug) 
        System.out.println("expression: " + $e.exprString);
      // can check if contains a decimal but doesnt check types of variables
      $typeOf = $e.typeOf;
      $isExpr = $e.isExpression;
    }
	) {
    if(!$isError) {
      // Get if var already exists
      Identifier newID = getVariable($name.getText());
	      // mismatch type to an existing variable, dont error on unknown
      boolean doAssign = true;
      if(newID != null) {
        if(!$typeOf.equals(Types.UNKNOWN) && !newID.type.equals(Types.UNKNOWN)){
            if(!(newID.type.equals(Types.DOUBLE) && $typeOf.equals(Types.INT))) // a double can be assigned an int
            {
            if(!$typeOf.equals(newID.type)){
              error($name, "invalid assignment, type does not match | current: " + newID.type + " new: " + $typeOf);
              doAssign = false;
            }
          } 
        }
      }
      if(doAssign){
          if(newID == null) { // if not already exists create new var
                String assignmentString = "";
                if($isVar) {
                  String v = "";
                  if($typeOf.equals(Types.DOUBLE)) v = "0.0";
                  else if($typeOf.equals(Types.INT)) v = "0";
                  generateAssignOrReassign($name.getText(), v, $typeOf);
                  assignVarToVar($name.getText(), $v.getText(), $typeOf);
                } else if($isExpr) {
                  generateAssignOrReassign($name.getText(), "0", $typeOf);
                  multiplyDoubleVars($name.getText(), $e.f1, $e.f2);
                  System.out.println($e.sign);
                  if($e.sign.equals("multiply"))
                    multiplyDoubleVars($name.getText(), $e.f1, $e.f2);
                  else if($e.sign.equals("plus"))
                    addDoubleVars($name.getText(), $e.f1, $e.f2);

                }else if($typeOf.equals(Types.ARRAY)) {
                    generateArray($name.getText(), $a.typeOf, $a.values.toArray(new String[0]));
                } else {
                  generateAssignOrReassign($name.getText(), $value, $typeOf);
                }
                newID = createVariable($name.getText(), $value, $typeOf);
          } else { // if already exists then reassign
		          if($isExpr) {
                System.out.println("test");
	                if($e.sign.equals("multiply"))
                    multiplyDoubleVars($name.getText(), $e.f1, $e.f2);
                  else if($e.sign.equals("plus"))
                    addDoubleVars($name.getText(), $e.f1, $e.f2);
              }
            else if($isVar) {
                assignVarToVar(newID.id, $v.getText(), $typeOf);
            } else if($typeOf.equals(Types.ARRAY)){
                error($name,"Cannot reassign arrays");
            } else{
                generateReassign($name.getText(), $value, $typeOf);
            }
          }
      if(isDebug)
        System.out.println("Assigning | name: " + newID.id + " | value: " + newID.value + " | scope: " + newID.scope + " | Level: " + newID.scopeLevel + " | type: " + newID.type);
    }
  }
};

array
	returns[String typeOf, String javaType, ArrayList<String> values]:
	'[' {
    $values=new ArrayList<String>();
  } (
		(
			v = INT {
    $typeOf = Types.INT;
	  $javaType = "Integer";
    $values.add($v.getText());
  } (
				',' v = INT {
	    $values.add($v.getText());
  }
			)*
		)
		| (
			(
				v = DECIMAL {
    $typeOf = Types.DOUBLE;
    $javaType = "Double";
    $values.add($v.getText());
  }
			) (
				',' v = DECIMAL {
	    $values.add($v.getText());
  }
			)*
		)
		| (
			v = STRING {
    $typeOf = Types.STRING;
    $javaType = "String";
    $values.add($v.getText());
	  } (
				',' v = STRING {
    $values.add($v.getText());
  }
			)*
		)
	) ']' {
	    if(isDebug){
	      System.out.println("CREATED ARRAY: typeOf: " + $typeOf + " | values: " + String.join(", ", $values));
      }
  };

statement:
	append_to_array
	| remove_from_array
	| clear_array
	| get_from_array
	| replace_index_array
	| array_length
	| functionCall
	| for_statement
	| assignment
	| while_statement
	| input
	| expr
	| if_else
	| condition
	| output
	| 'break' {
      if(!loopReturnBlocks.empty())
          call(getCurrLoopReturn());
      
  }
	| 'continue' {
      if(!isScopeGlobal())
        addLoopCall();
  }
	// needed to move because returns need to be allowed in loops and ifs within functions
	| (at = 'return' y = varExprOrType | expr) { //will most likely need to edit this for recursion
    if(isScopeGlobal()) {
      error($at, "error attempting to call return outside a function");
      } {
        String b = $y.asText;
        if(isFunctionReturning == 1) {
          // addCodeLine("return " + $y.asText + ";");
          System.out.println("Return values not implemented");
        } else {
          error($at, "Error: function does not return a value");
        }
        }
  }
	| (at = 'return') { //will most likely need to edit this for recursion
    if(isScopeGlobal()) {
      error($at, "error attempting to call return outside a function");
      } {
        if(isFunctionReturning == 0) {
          // addCodeLine("return;");
          addReturnVoidCall();
        } else {
          error($at, "Error: function must return a value");
        }
        }
  };

clear_array:
	'clear ' n = VARIABLE_NAME {
  ARRAYS.get($n.getText()).clear();
};
append_to_array:
	'add ' v = varExprOrType ' to ' n = VARIABLE_NAME {
    RiscArray arr = ARRAYS.get($n.getText());
    if(arr == null) {
      error($n, "Error array does not exist");
    } else {
    if($v.typeOf.equals(Types.VARIABLE)) {

      Identifier var = getVariable($v.asText);
      if(!var.type.equals(arr.type)) {
        error($n, "var type does not match array type");
      } else {
        arr.add($v.asText, true);
      }
      } else if(!$v.typeOf.equals(arr.type) || $v.isExpression) {
        error($n, "type of array does not match input");
      } else {
        arr.add($v.asText, false);
      }
    }
};

array_length:
	'assign ' v = VARIABLE_NAME ' length of ' n = VARIABLE_NAME {
      Identifier var = getVariable($v.getText());
      if(ARRAYS.get($n.getText()) == null) {
        error($n, "Error array does not exist");
      } else if(var == null) {
          createVariable($v.getText(), "0", Types.INT);
          // generateIntAssign($v.getText(), size+"");
          ARRAYS.get($n.getText()).assignSize($v.getText());
      } else if(var.type != Types.INT) {
        error($v, "Can only assign length of array to an int");
      }else {
            // int size = ARRAYS.get($n.getText()).size();
            // reassignInt($v.getText(), size+"");
            ARRAYS.get($n.getText()).assignSize($v.getText());
      }
  };
replace_index_array
	locals[int index, boolean isIndexVar]:
	'replace index ' (
		i = INT {
        $index = Integer.parseInt($i.getText()) - 1;
	  }
		| i_v = VARIABLE_NAME {
		    $isIndexVar = true;
    }
	) ' with ' v = varExprOrType ' from ' n = VARIABLE_NAME {
    RiscArray arr = ARRAYS.get($n.getText());
    if(arr == null) {
      error($n, "Error array does not exist");
    } else {
      arr.set($index, $v.asText, $isIndexVar, $v.isVar);
    }
};
remove_from_array
	locals[String index_code, int index]:
	'remove index ' (
		i = INT {
      int index = Integer.parseInt($i.getText()) - 1;
    }
		| v = VARIABLE_NAME {
    // TODO
  }
	) ' from ' n = VARIABLE_NAME {
    RiscArray arr = ARRAYS.get($n.getText());
   
    if(arr == null) {
      error($n, "Error array does not exist");
    } else {
      arr.remove($index);
    }
};

get_from_array
	locals[int index]:
	'assign ' v = VARIABLE_NAME ' index ' (
		i = INT {
	        $index = (Integer.parseInt($i.getText()) - 1);
	  }
		| i_v = VARIABLE_NAME {
      // TODO get index from a variable
      Identifier id = getVariable($i_v.getText());
      if(id == null) {
        error($i_v, "variable does not exist");
      } if(!id.type.equals(Types.INT)) {
        error($i_v, "variable is not an int");
      } else {
        $index = Integer.parseInt(id.value)-1;
      }
    }
	) ' from ' n = VARIABLE_NAME {
  RiscArray arr = ARRAYS.get($n.getText());
  Identifier newID = getVariable($v.getText());
    if(arr == null)  {
	      error($n, "array does not exist");
    } else {
      String arrType = arr.type;
      if(newID != null && !arrType.equals(newID.type)) {
        error($n, "type of array does not match type of variable");
      } else {
        if(newID == null) {
            newID = createVariable($v.getText(), "", arrType);
            if(arrType.equals(Types.DOUBLE)) {
              generateDoubleAssign(newID.id, "0.0");
            } else if(arrType.equals(Types.INT)) {
              generateIntAssign(newID.id, "0");
            } else if(arrType.equals(Types.STRING)) {
              generateStringAssign(newID.id, "");
            }
        } 
        // TODO
          // assignVarToVar(newID.id, arr.variables.get($index), arrType);
      }
    }
};
square_root
	returns[float value, String exprString, boolean hasKnownValue]:
	'square root' c = VARIABLE_NAME {
    Identifier var = getVariable($c.getText());
    $exprString = "Math.sqrt(" + var.id + ")";
    $hasKnownValue = false;
  }
	| 'square root' e = expr {
      $value = $e.value;
      $exprString = "Math.sqrt(" + String.valueOf($e.value) + ")";   
      $hasKnownValue = $e.hasKnownValue;
    };
expr
	returns[boolean hasKnownValue, float value, String exprString, String typeOf, boolean isExpression, String f1, String sign, String f2]
		:
	a = word {
      $f1 = $a.left;
      $sign = $a.sign;
      $f2 = $a.right;


	    $isExpression = $a.isExpression;
      $exprString = $a.exprString;
      $typeOf = $a.isDouble ? Types.DOUBLE : Types.INT;
      if ($a.hasKnownValue) {
        $hasKnownValue = true;
        $value = $a.value;
      } else {
        $hasKnownValue = false;
      } 
    } (
		op = ('plus' | 'minus') b = word {
      // $f2 = $b.value + "";
      $f2 = $b.left;
      $sign = $op.getText();
      $isExpression = true;
      if($b.isDouble) {
        $typeOf = Types.DOUBLE;
      }
        if ($op.getText().equals("plus")) {
		      $exprString += $b.exprString;
          if ($hasKnownValue && $b.hasKnownValue)
            $value = $value + $b.value;
          // addCodeLine($exprString + "    fadd.d   ft0, ft0  ft1");
        } else {
		        $exprString += $b.exprString;
          if ($hasKnownValue && $b.hasKnownValue)
            $value = $value - $b.value;
          // addCodeLine($exprString + "    fsub.d   ft0, ft0  ft1");
        }
	  $isExpression = true;
    }
	)*;

word
	returns[boolean hasKnownValue, float value, String exprString, boolean isDouble, boolean isExpression, String left, String right, String sign]
		:
	a = factor {
      $left = $a.factorString;
      $exprString = $a.factorString;
      $isDouble = $a.isDouble;
      if ($a.hasKnownValue) {
        $hasKnownValue = true;
        $value = $a.value;
      } else $hasKnownValue = false;
    } (
		op = ('multiply' | 'divide' | 'mod') b = factor {
	      $sign = $op.getText();
        $right = $b.factorString;
        
        if($op.getText().equals("divide")) {
              $exprString += $b.factorString;
              // addCodeLine($exprString + "    fdiv.d   ft0, ft0  ft1");
	        } else if($op.getText().equals("multiply")) {
              $exprString += $b.factorString;
              // addCodeLine($exprString + "    fmul.d   ft0, ft0  ft1");
	        } else if($op.getText().equals("mod")) {
              $exprString +=" % " + $b.factorString;
        } 
        if($b.isDouble) {          
	          $isDouble = true;
        }


        if ($b.hasKnownValue && $op.getText().equals("divide") && $b.value == 0) {
          $hasKnownValue = false;
        } else if ($hasKnownValue && $b.hasKnownValue) {
          if ($op.getText().equals("multiply")) {
            // $value = $value * $b.value;
          } else if ($op.getText().equals("divide")){
            // $value = $value / $b.value;
          }
        } else {
          $hasKnownValue = false;
        }

	        $isExpression = true;
      }
	)*;

factor
	returns[boolean hasKnownValue, float value, String factorString, boolean isDouble]:
	INT {
      $hasKnownValue = true; 
      $value = Integer.parseInt($INT.getText()); 
		  $factorString = ""+$INT.getText();
    }
	| DECIMAL {
	  $isDouble = true;
    $hasKnownValue = true; 
    $value = Float.parseFloat($DECIMAL.getText());
		$factorString = ""+$DECIMAL.getText();
    }
	| VARIABLE_NAME {
		      $factorString = $VARIABLE_NAME.getText();
        String id = $VARIABLE_NAME.getText();
	      // $factorString = generateLoadId(id);
        used.add(id);
        // If we're in the middle of first assignment to VARIABLE_NAME (self-reference):
        if (!doesVariableExist(id)) {
          // General use-before-assign.

          // error($VARIABLE_NAME, "use of variable '" + id + "' before assignment");
        } else {
          String t = getVariable(id).type;
          if(t.equals(Types.DOUBLE)) {
            $isDouble = true;
	          } else if(!t.equals(Types.INT)) {
              if (getScope().equals("Global")) {  
	              error($VARIABLE_NAME, id + " is not an int or double");
              }
          }
        }
        $hasKnownValue = false;
      }
	| square_root {
        $factorString = $square_root.exprString;
        $isDouble = true;
        $hasKnownValue = true;
        if ( $square_root.hasKnownValue ) {
          $value = $square_root.value;
        }
      }
	| '(' expr ')' { 
		    $factorString = '('+ $expr.exprString +')';
        $isDouble = $expr.typeOf.equals(Types.DOUBLE);
        if ($expr.hasKnownValue) {
          $hasKnownValue = true;
          $value = $expr.value;
        } else {
          $hasKnownValue = false;
        }
	      };

conditional_statement
	returns[String conditionSign, boolean isNot]: (
		(
			'not' {
      $isNot = true;
    }
		)? (
			'equal to' {
      $conditionSign = "==";
      }
			| 'less than or equal to' {
      $conditionSign = "<=";
      }
			| 'greater than or equal to' {
      $conditionSign = ">=";
      }
			| 'greater than' {
      $conditionSign = ">";
      }
			| 'less than' {
      $conditionSign = "<";
      }
		)
	);
condition
	returns[String a, String b, String leftType, String rightType, String risc_word, String condition_sign, boolean isNot]
		:
	(
		x = INT {$leftType = Types.INT;}
		| x = DECIMAL {$leftType = Types.DOUBLE;}
		| x = VARIABLE_NAME {$leftType = Types.VARIABLE;}
	) {
    $a = $x.getText();
} c = conditional_statement {
    $isNot = $c.isNot;
    $condition_sign = $c.conditionSign;

    switch($condition_sign) {
      case ">":
        $risc_word = "gt";
        break;
      
      case "<":
        $risc_word = "lt";
        break;
      
      case "==":
        if($isNot) {
          $risc_word = "eq";
        } else {
          $risc_word = "ne";
        }
        break;

      case ">=":
        $risc_word = "ge";
        break;
      
      case "<=":
        $risc_word = "le";
        break;
      
    }

    System.out.println($condition_sign + " " +$risc_word);
} (
		y = INT {$rightType = Types.INT;}
		| y = DECIMAL {$rightType = Types.DOUBLE;}
		| y = VARIABLE_NAME {$rightType = Types.VARIABLE;}
	) {
    $b = $y.getText();
};
if_statement
	returns[String a, String b, String leftType, String rightType, String risc_word, boolean isNot, boolean failed]
		:
	i = 'is' c = condition {
    $a = $c.a;
    $b = $c.b;
    $leftType = $c.leftType;
    $rightType = $c.rightType;
    $risc_word = $c.risc_word;
    $isNot = $c.isNot;

    String lSubT = $leftType;
    String rSubT = $rightType;
    if($leftType.equals(Types.VARIABLE)) {
      lSubT = getVariable($a).type;
      if(!(lSubT.equals(Types.DOUBLE) || lSubT.equals(Types.INT))) {
	        $failed = true;
	        error($i, " conditionals can only compare ints and decimals");
      } 
    }
    if($rightType.equals(Types.VARIABLE)) {
      rSubT = getVariable($b).type;
        if(!(rSubT.equals(Types.DOUBLE) || rSubT.equals(Types.INT))) {
          $failed = true;
	        error($i, " conditionals can only compare ints and decimals");
      } 
    }
    if(!lSubT.equals(rSubT)) {
      $failed = true;
      error($i, " conditionals can only compare variables or constants of the same exact type");
    }
    };
else_statement: 'if not';

if_scope:
	'{' {
    addScopeLevel();
    } statement* '}' {
      removeScopeLevel();
    };

if_else
	locals[int index, String ifBlock, String elseBlock, String afterBlock]:
	i = if_statement {
	    if(!$i.failed) {
        condition_index++;
        $index = condition_index;
        $ifBlock = "____IF____protected___Conditional____" + $index;
        $afterBlock = "____AFTER____protected___Conditional____" + $index;
        $elseBlock = "____ELSE____protected___Conditional____" + $index;



        genConditionalCode($i.a, $i.b, $i.leftType, $i.rightType, $i.risc_word, $ifBlock);
        addCodeLine("call " + $elseBlock);
        addCodeLine($ifBlock + ": ");
      }

  } is = if_scope {
    addCodeLine("call " + $afterBlock);
    addCodeLine($elseBlock + ": ");

  } (else_statement ifel = if_else)* (
		e = else_statement is = if_scope
	)? {
    addCodeLine($afterBlock + ": ");
  };

for_statement
	returns[String loop_block_name, String return_to_block, String i_name]
	locals[String repeat_assign_code]:
	'repeat' (
		n = INT {
      $repeat_assign_code = "li t1, " + $n.getText();
  }
		| v = VARIABLE_NAME {
	    $repeat_assign_code = "la t2, " + $v.getText()
      + "\n\tlw t1, (t2)";
  }
	) {
	    loop_index++;
      $loop_block_name="______protected___loop____" + loop_index;
      $return_to_block = "____return_from" + $loop_block_name;
      $i_name = "____loop_index____" +loop_index;
      
      // init "i"
      generateInitialAssign($i_name, "0", Types.INT);
      // set i to be the num repeats
      addCodeLine("la t0, " + $i_name);
      addCodeLine($repeat_assign_code);
      addCodeLine("sw t1, (t0)");
      enterLoop($loop_block_name, $return_to_block);
      
      addCodeLine($loop_block_name + ":");
      addCodeLine("la t0, " + $i_name); // get i address (t0)
      addCodeLine("lw t1, (t0)"); // load i number (t1)
      addCodeLine("beqz t1, "+ $return_to_block);

      addCodeLine("addi t1, t1, -1"); // -1
      addCodeLine("sw t1, (t0)"); // store back to i
  } loopScope {
      addLoopCall();
      addCodeLine($return_to_block + ":");
      finishLoop();
  };

while_statement
	returns[String conditional, String loop_block_name, String return_to_block, String check_block]:
	'while' c = condition {
    $loop_block_name="______protected___loop____" + loop_index++;
    $return_to_block = "____return_from" + $loop_block_name;
    $check_block = "___CHECK" + $loop_block_name;

    enterLoop($loop_block_name, $return_to_block);

    addCodeLine($check_block+":");

    genConditionalCode($c.a, $c.b, $c.leftType, $c.rightType, $c.risc_word, $loop_block_name);
    call($return_to_block);
    addCodeLine($loop_block_name + ": ");

    

  } loopScope {
      // addLoopCall();
      call($check_block);
      addCodeLine($return_to_block + ":");
      finishLoop();
  };

loopScope:
	'{' {
	  addScopeLevel();
    } statement* '}' {
    removeScopeLevel();
    };

functionDefinition
	returns[String name, int arity, boolean doesReturn, String returnType, String value]
	locals[ArrayList<String> variableParamNames, ArrayList<String> varTypeAndName, String varType, String s, ArrayList<String> paramTypes, ArrayList<String> paramTypes]
		:
	'define' {$returnType = "void";} (
		r = VARIABLE_NAME {
    $returnType = $r.getText();
    if($returnType.startsWith("list")) {
        String arrayType = $returnType.split("_")[1].toLowerCase();
          $returnType = Types.ARRAY;
          if(arrayType.equals("int")) {}
          else if(arrayType.equals("double")) {} 
          if(arrayType.equals("string")) {}

        } else if($returnType.equals("int")) {
	        $returnType = Types.INT;
        }else if($returnType.equals("double")) {
          $returnType = Types.DOUBLE;
        } if($returnType.equals("string")) {
          $returnType = Types.STRING;
        }
  }
	)? n = VARIABLE_NAME {
    $name = $n.getText();
	  $variableParamNames = new ArrayList<String>();
    $varTypeAndName = new ArrayList<String>();
    $paramTypes = new ArrayList<String>();
  } '(' (
		VARIABLE_NAME {
      $varType = $VARIABLE_NAME.getText();
        if ($varType.startsWith("list")){
          $varType = Types.ARRAY;
        }else if($varType.equals("int")) {
          $varType = Types.INT;
        }else if($varType.equals("double")) {
          $varType = Types.DOUBLE;
        } if($varType.equals("string")) {
          $varType = Types.STRING;
        }
      $paramTypes.add($varType);
    } VARIABLE_NAME {
		      $variableParamNames.add($VARIABLE_NAME.getText());
    } (
			',' VARIABLE_NAME {
        $varType = $VARIABLE_NAME.getText();
        if ($varType.startsWith("list")){
          $varType = Types.ARRAY;
        } else  if($varType.equals("int")) {
          $varType = Types.INT;
        }else if($varType.equals("double")) {
          $varType = Types.DOUBLE;
        } if($varType.equals("string")) {
          $varType = Types.STRING;
        }

        $paramTypes.add($varType);
      } VARIABLE_NAME {
	        $variableParamNames.add($VARIABLE_NAME.getText());
      }
		)*
	)? ')' '{' { 
    if(doesFunctionExist($name)) {
      error($n, "Error: function " + $name + "already Exists");
    } else {
      $arity = $variableParamNames.size();
		      FunctionIdentifier fid = createFunction($name, $arity, $doesReturn, $returnType, $paramTypes, $variableParamNames);
      setScope(fid.name);

      for(int i = 0; i < $variableParamNames.size(); i++) {
        String varName = $variableParamNames.get(i);
        String type = $paramTypes.get(i);
        generateAssignOrReassign(varName, "0", type);
          if (type.startsWith("ArrayList") || type.startsWith("list")) {
              String arrayType = "";
              if(type.startsWith("list")) {
                arrayType = type.split("_")[1];
              } else {
                arrayType = type.substring(type.indexOf('<') + 1, type.indexOf('>'));
              }
            arrayType = arrayType.toLowerCase();
            Identifier A_ID = createVariable(varName, "<FUNCTION_PARAM>", Types.ARRAY);

            if(arrayType.equals("integer")) {
              arrayType = Types.INT;
            } else if(arrayType.equals("double")) {
              arrayType = Types.DOUBLE;
            } else if(arrayType.equals("string")) {
              arrayType = Types.STRING;
            } else if(arrayType.equals("boolean")) {
              arrayType = Types.BOOL;
            }
            A_ID.arrayType = arrayType;
	            
        } else {
          createVariable(varName, "0", type);
        }
        if(isDebug) {
          System.out.println("Adding " + varName + " to " + $name + " scope");
        }      
      }
      if(!$returnType.equals("void")) {
        $doesReturn = true;
        isFunctionReturning = 1;
      } else {
        $doesReturn = false;
        isFunctionReturning = 0;
      }
    }
    
} (
		statement
		| ('define') {
      error($n, "Error can't define function in a function");
    }
	)* '}' {
    functionList.add(getFunction($name));
    isFunctionReturning = -1;
    addReturnVoidCall();
    
    exitMainScope();
};

functionCall
	returns[String name, boolean doesReturn, boolean isSuccess, ArrayList<String> params, String code, String value, String asText]
	locals[int arity, boolean isAssignment, String funType]:
	(
		variable = VARIABLE_NAME '=' {
    $isAssignment = true;
  }
	)? n = VARIABLE_NAME '(' (
		v = varExprOrType {
    $params = new ArrayList<String>();
    $params.add($v.asText);
    $arity +=1;
  } (
			',' v = varExprOrType {
     $params.add($v.asText);
     $arity +=1;
  }
		)*
	)? ')' {
    $name = $n.getText();
    if(!doesFunctionExist($name)) {
      error($n, "Error: attempting to call a function that does not exist");
    } else {
      FunctionIdentifier fid = getFunction($name);
      $funType = fid.returnType;
      if(fid.arity != $arity) {
        error($n, "attempting to call a function with incorrect number of arguments");
      } else {
        $doesReturn = fid.doesReturn;
        $isSuccess = true;
      }

      for(int i =0; i < $arity; i++) {
        fid.assignOrReassign(i, $params.get(i));
      }

        if($isAssignment) {
	        Identifier ID = getVariable($variable.getText());
            if(ID == null) {
              ID = createVariable($variable.getText(), $code, $funType);
              $code = $funType + " " + ID.id + "=" + $code;
            } else {     
              $code = ID.id + "=" + $code;
        }
      }
        
        addCodeLine("jal " + fid.block_name);

    }
  };

input: input_decimal | input_string | input_number;

input_string:
	'input string ' a = VARIABLE_NAME {
        addCodeLine(".data \n\ttmp_input_space: .space 200 \n\t.text");
        addCodeLine("li a7, 8"
        + "\n\t la a0, tmp_input_space"  // address to store to
        + "\n\tli a1, 200" // max length
        + "\n\tecall");        

        // assign var string tmp_input_space
        addCodeLine("la t0, " + $a.getText()
	        + "\n\tla t1, tmp_input_space"
        + "\n\tsw t1, (t0)");
};
input_number:
	'input number ' a = VARIABLE_NAME {
	    addCodeLine("li a7, 5"); // stores to a0 
      addCodeLine("ecall");
      addCodeLine("la t0, " + $a.getText());
      addCodeLine("sw a0 (t0)");
};
input_decimal:
	'input decimal ' a = VARIABLE_NAME {
	      addCodeLine("li a7, 7"); // stores to fa0
        addCodeLine("ecall");
        addCodeLine("la t0, " + $a.getText());
        addCodeLine("fsd fa0 (t0)");
};

printType
	returns[Boolean hasKnownValue, String value, boolean isVar]:
	(v = INT | v = DECIMAL) {
    $hasKnownValue = true; 
    $value = $v.getText();
  }
	| STRING {
    $hasKnownValue = true; 
    $value = $STRING.getText();

    // remove ""
	    $value = $value.substring(1, $value.length() - 1);
    }
	| VARIABLE_NAME {
      $isVar = true;
        Identifier id = getVariable($VARIABLE_NAME.getText());
        used.add(id.id);
        // If we're in the middle of first assignment to VARIABLE_NAME (self-reference):
        if (id == null) {
          // General use-before-assign.
	          error($VARIABLE_NAME, "use of variable '" + $VARIABLE_NAME.getText() + "' before assignment");
        } else{
          // var exists
          printVar(id.id, id.type);
        }
        $hasKnownValue = false;
      }
	| expr {
          $hasKnownValue = true; 
          $value = String.valueOf($expr.value); 
		};

output
	locals[boolean inline]:
	(
		'print' v = printType (
			'inline' {
      $inline=true;
  }
		)?
	) {
    if(!$v.isVar) addPrintLine($v.value);
      if(!$inline) addPrintNewLine();
    
};

varExprOrType
	returns[String asText, String typeOf, boolean isExpression, boolean isVar]:
	(
		t = VARIABLE_NAME {$typeOf=Types.VARIABLE; $isVar=true;}
		| t = STRING {$typeOf=Types.STRING;}
		| t = BOOL {$typeOf=Types.BOOL;}
	) {
    $asText=$t.getText();
  }
	| e = expr {
      $typeOf=$e.typeOf;
      $isExpression = $e.isExpression;
	    $asText = $e.exprString;
  }
	| f = functionCall {
	      $typeOf=Types.FUNCTION_CALL;
      $asText = $f.value;
  };
type: INT | STRING | DECIMAL | BOOL;

STRING: '"' ( ~["])* '"';
INT: '-'? [0-9]+;
BOOL: 'True' | 'False' | 'true' | 'false';
DECIMAL: '-'? [0-9]* '.' [0-9]*;
VARIABLE_NAME: ([a-z] | [A-Z] | '_' | '<' | '>')+;
COMMENT_LINE: '*' ~[\n\r]* -> skip;

// skip comments
WHITESPACE: [ \r\n\t]+ -> skip;
// skip extra white space ~[\n\r]* -> skip;