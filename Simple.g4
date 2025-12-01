grammar Simple;
// -------- Parser Members: global state for simple semantic checks --------
@header { import java.util.*; import java.io.*;}

@members {
  boolean isDebug = true;

  class Types {
    static String STRING = "String";
    static String INT = "int";
    static String DOUBLE = "double";
    static String ARRAY= "array";
    static String BOOL = "boolean";
    static String FUNCTION_CALL = "function call";
    static String UNKNOWN = "unknown";
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
    ArrayList<Identifier> Params;
    boolean doesReturn;
    String returnType;
    ArrayList<String> code = new ArrayList<String>();

    void addLine(String line) {
      code.add(line);
    }
  }

  void addCodeLine(String line) {
    if(isScopeGlobal()) {
	      globalCodeLines.add(line);
    } else {
	      functionTable.get(getScope()).addLine(line);
    }
  }


  int strIteration = 0;
  void addPrintLine(String line) {
    String ref = "pstr" + strIteration;
	      strIteration++;

	    String assignStr = ".data\n"
      + ref+": .asciz \""
        + line
        + "\"\n"
        + ".text";

		  String printStr = "la    a0, "+ref
	      + "\nli    a7, 4"
        +"\necall";
	    if(isScopeGlobal()) {
	      globalCodeLines.add(assignStr + "\n" + printStr);
    }
  }

  ArrayList<String> globalCodeLines = new ArrayList<String>();
  Map<String, FunctionIdentifier> functionTable = new HashMap();
  ArrayList<FunctionIdentifier> functionList = new ArrayList<FunctionIdentifier>();
  FunctionIdentifier getFunction(String name) {
    return functionTable.get(name);
  }


  FunctionIdentifier createFunction(String name, int arity, boolean doesReturn, String returnType) {
    FunctionIdentifier fid = new FunctionIdentifier();
    fid.name = name;
    fid.arity = arity;
    fid.doesReturn = doesReturn;
    fid.returnType = returnType;
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
        put("Global", new ArrayList<SymbolTable>());
      }
  }

  int isFunctionReturning = 0;

	ScopedSymbolTable scopedSymbolTable = new ScopedSymbolTable();
  int scopeLevel = 0;
  String currScope = "Global";
  
  void setMainScope(String functionName) {
    currScope = functionName;
    scopedSymbolTable.put(functionName, new ArrayList<SymbolTable>());
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
	    ArrayList<SymbolTable> tables = scopedSymbolTable.get(getScope());
      if(tables.size() == 0) {
        tables.add(new SymbolTable());
      }
      return tables.get(tables.size() - 1);
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
  StringBuilder sb2 = new StringBuilder();
  
  
  void emit(String s) {sb.append(s);}   
  //File generation
  void openProgram() {
    // emit("import java.util.*;\n");
    // emit("public class SimpleProgram {\n");
    // emit("static Scanner ___protected___in___ = new Scanner(System.in);\n");


	    emit("main:\n\t");
  }

  void writeFile() {
    try (PrintWriter pw = new PrintWriter("SimpleProgram.S", "UTF-8")) {
      for(int i=0; i<functionList.size(); i++) {
        FunctionIdentifier fid = functionList.get(i);
        for(String line : fid.code) {
          sb.append(line + "\n");
        }
      }
      pw.print(sb.toString());
      // pw.print("public static void main(String[] args) throws Exception {\n");
      for(String line : globalCodeLines) {
          sb2.append(line + "\n");
      } 
      pw.print(sb2.toString());


      // pw.print("}\n}\n");
    } catch (Exception e) {
      System.err.println("error: failed to write SimpleProgram.java: " + e.getMessage());
    }

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
	locals[String value, String typeOf, boolean isError]:
	name = VARIABLE_NAME '=' (
		t = DECIMAL {
      $typeOf = Types.DOUBLE;
	    $value = $t.getText();
    }
		| t = INT {
      $typeOf = Types.INT;
	    $value = $t.getText();
    }
		| e = expr {
	    if(isDebug)
        System.out.println("expression: " + $e.exprString);
      // can check if contains a decimal but doesnt check types of variables
      $typeOf = $e.typeOf;
      // $value = String.valueOf($e.value);
      $value=$e.exprString;
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
      } else if (var.scope != "global" && var.scope != getScope()) {
          error($v, "Error attempting to assign a variable that is not defined (there is a variable defined that is out of scope)");
          $isError = true;
      } else {
	        $value = var.value;    
        $typeOf = var.type;
      }
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
                newID = createVariable($name.getText(), $value, $typeOf);

                String assignmentString = "";
                if($typeOf.equals(Types.DOUBLE)) {
                    assignmentString = "double ";
		            } else if($typeOf.equals(Types.BOOL)) {
                    assignmentString = "boolean ";
                }
                else if($typeOf.equals(Types.INT)) {
                    assignmentString = "int ";
                } else if($typeOf.equals(Types.STRING)) {
                    assignmentString = "String ";
	              } else if($typeOf.equals(Types.ARRAY)) {
                  assignmentString = "ArrayList<" + $a.javaType +"> ";
                  newID.arrayType = $a.typeOf;
                  if(isDebug)
                    System.out.println(">>Array type: " +  newID.arrayType);
                    assignmentString += newID.id + "= new ArrayList<" + $a.javaType + ">();";
                  // addCodeLine(assignmentString);
		              String appendString = "Collections.addAll("+newID.id+", new "+ $a.javaType +"[]{";
                  // add values
                  boolean isFirst = true;
                  for(String v : $a.values) {
                    if(isFirst) {
                      isFirst=false;
                      appendString += v;
                      continue;
                    } else {
	                    appendString += "," + v;
                    }
                  }
                  appendString+="});";
                  // addCodeLine(appendString);

                }
              if(!$typeOf.equals(Types.ARRAY)){
	                assignmentString += $name.getText() + "=" + $value + ";";
                  // addCodeLine(assignmentString);
                }

          } else { // if already exists then reassign
	              if($typeOf.equals(Types.ARRAY)){
	                error($name,"Cannot reassign arrays");
                }
              newID.value = $value;
              // addCodeLine(newID.id + "=" + $value + ";");

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
	| assignment
	| for_statement
	| while_statement
	| input
	| expr
	| if_else
	| condition
	| output
	| 'break' {
	    // addCodeLine("break;");  
  }
	| 'continue' {
	    // addCodeLine("continue;");  
  }
	// needed to move because returns need to be allowed in loops and ifs within functions
	| (at = 'return' y = varExprOrType | expr) { //will most likely need to edit this for recursion
    if(isScopeGlobal()) {
      error($at, "error attempting to call return outside a function");
      } {
        String b = $y.asText;
        if(isFunctionReturning == 1) {
          // addCodeLine("return " + $y.asText + ";");
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
        } else {
          error($at, "Error: function must return a value");
        }
        }
  };

clear_array:
	'clear ' n = VARIABLE_NAME {
  // addCodeLine($n.getText() + ".clear();");
};
append_to_array:
	'add ' v = varExprOrType ' to ' n = VARIABLE_NAME {
  // addCodeLine($n.getText() + ".add(" + $v.asText + ");");
};

array_length:
	'assign ' v = VARIABLE_NAME ' length of ' n = VARIABLE_NAME {
	    // addCodeLine($v.getText() + "=" + $n.getText() + ".size();");
  };
replace_index_array
	locals[String index_code]:
	'replace index ' (
		i = INT {
		      $index_code = "" + (Integer.parseInt($i.getText()) - 1);
	  }
		| i_v = VARIABLE_NAME {
	      $index_code = $i_v.getText();
    }
	) ' with ' v = VARIABLE_NAME ' from ' l = VARIABLE_NAME {
	  // addCodeLine($l.getText() + ".set(" + $index_code + ", " + $v.getText() + ");");
};
remove_from_array
	locals[String index_code]:
	'remove index ' (
		i = INT {
		      $index_code = "" + (Integer.parseInt($i.getText()) - 1);
	  }
		| i_v = VARIABLE_NAME {
	      $index_code = $i_v.getText();
    }
	) ' from ' n = VARIABLE_NAME {
	  // addCodeLine($n.getText() + ".remove(" + $index_code + ");");
};

get_from_array
	locals[String index_code]:
	'assign ' v = VARIABLE_NAME ' index ' (
		i = INT {
		      $index_code = "" + (Integer.parseInt($i.getText()) - 1);
	  }
		| i_v = VARIABLE_NAME {
	      $index_code = $i_v.getText();
    }
	) ' from ' n = VARIABLE_NAME {
  Identifier arrayID = getVariable($n.getText());
  Identifier newID = getVariable($v.getText());
    if(arrayID == null)  {
	      error($n, "array does not exist");
    } else {
      String type = "";
      if(newID == null) {
          newID = createVariable($v.getText(), "", arrayID.arrayType);
          type = newID.type;
        } 
      if(!arrayID.arrayType.equals(newID.type)) {
        error($n, "type of array does not match type of variable");
      }  else {

        // addCodeLine(type + " " + $v.getText() + "="+$n.getText() + ".get(" + $index_code + ");");
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
	returns[boolean hasKnownValue, float value, String exprString, String typeOf]:
	a = word {
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
      if($b.isDouble) {
        $typeOf = Types.DOUBLE;
      }
        if ($op.getText().equals("plus")) {
		      $exprString += " + " + $b.exprString;
          if ($hasKnownValue && $b.hasKnownValue)
            $value = $value + $b.value;
        } else {
		        $exprString += " - " + $b.exprString;
          if ($hasKnownValue && $b.hasKnownValue)
            $value = $value - $b.value;
        }
    }
	)*;

word
	returns[boolean hasKnownValue, float value, String exprString, boolean isDouble]:
	a = factor {
      $exprString = $a.factorString;
      $isDouble = $a.isDouble;
      if ($a.hasKnownValue) {
        $hasKnownValue = true;
        $value = $a.value;
      } else $hasKnownValue = false;
    } (
		op = ('multiply' | 'divide' | 'mod') b = factor {
        if($op.getText().equals("divide")) {
              $exprString += " / " + $b.factorString;
	        } else if($op.getText().equals("multiply")) {
              $exprString += " * " + $b.factorString;
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
            $value = $value * $b.value;
          } else if ($op.getText().equals("divide")){
            $value = $value / $b.value;
          }
        } else {
          $hasKnownValue = false;
        }
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
        String id = $VARIABLE_NAME.getText();
	      $factorString=id;
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
	returns[String conditional]:
	a = varExprOrType {
	    $conditional=$a.asText;
} c = conditional_statement {
if($c.isNot) $conditional = "!(" + $conditional;
	$conditional += $c.conditionSign;
} b = varExprOrType {
		$conditional+=$b.asText;
    if($c.isNot) $conditional +=")";
    if(isDebug)
      System.out.println($conditional);
};

if_statement
	returns[String conditional]:
	'is' c = condition {
	  $conditional = $c.conditional;
    // addCodeLine("if(" + $conditional + ")");
};
else_statement:
	'if not' {
  // addCodeLine("else");
};

if_scope:
	'{' {
    addScopeLevel();
    // addCodeLine("{"); // } – for some reason quoted brackets mess up vscode
    } statement* '}' {removeScopeLevel();
    // { – for some reason quoted brackets mess up vscode
    // addCodeLine("}");
    };

if_else:
	if_statement if_scope (else_statement if_statement if_scope)* (
		else_statement if_scope
	)?;

for_statement
	returns[String repeats]:
	'repeat' (n = INT | n = VARIABLE_NAME) {
   $repeats = $n.getText();

   String i_name = "____protected_index____" + getScopeLevel();
	//  addCodeLine("for (int " +i_name +" = 0; " +i_name +" < " + $repeats + "; " +i_name +"++)" + " {"); // } 
  } loopScope;

while_statement
	returns[String conditional]:
	'while' c = condition {
    $conditional = $c.conditional;
    // addCodeLine("while(" + $conditional + ") {"); //}
  } loopScope;

loopScope:
	'{' {
	  addScopeLevel();
    } (
		statement
		| 'continue' {
	      //  addCodeLine("continue;");   
    }
		| 'break' {
	      // addCodeLine("break;");   
    }
	)* '}' {removeScopeLevel();
    // { – for some reason quoted brackets mess up vscode
    // addCodeLine("}");
    };

functionDefinition
	returns[String name, int arity, boolean doesReturn, String returnType, String value]
	locals[ArrayList<String> variableParamNames, ArrayList<String> varTypeAndName, String varType, String s, ArrayList<String> paramJavaTypes]
		:
	'define' r = VARIABLE_NAME {
    $returnType = $r.getText();
    if($returnType.startsWith("list")) {
		      String arrayType = $returnType.split("_")[1].toLowerCase();
		        if(arrayType.equals("int")) {
	          $returnType = "ArrayList<Integer>";
	          } else if(arrayType.equals("boolean")) {
	          $returnType = "ArrayList<Boolean>";
		          } else if(arrayType.equals("double")) {
	          $returnType = "ArrayList<Double>";
	          } if(arrayType.equals("string")) {
	          $returnType = "ArrayList<String>";
        }
    }
  } n = VARIABLE_NAME {
    $name = $n.getText();
	  $variableParamNames = new ArrayList<String>();
    $varTypeAndName = new ArrayList<String>();
    $paramJavaTypes = new ArrayList<String>();
  } '(' (
		VARIABLE_NAME {
      $varType = $VARIABLE_NAME.getText();
      if ($varType.equals("list_double"))
          $varType = "ArrayList<Double>";

      if ($varType.equals("list_boolean"))
          $varType = "ArrayList<Boolean>";

      if ($varType.equals("list_int"))
          $varType = "ArrayList<Integer>";

      if ($varType.equals("list_string"))
          $varType = "ArrayList<String>";
      $paramJavaTypes.add($varType);
    } VARIABLE_NAME {
		      $variableParamNames.add($VARIABLE_NAME.getText());
          $varTypeAndName.add($varType + " " + $VARIABLE_NAME.getText());
          for(int i=0; i< $varTypeAndName.size(); i++) {
          if(i==($varTypeAndName.size()-1)) {
            $s = $varTypeAndName.get(i);
          } else {
            $s += $varTypeAndName.get(i) + ", ";
          }
        }
    } (
			',' VARIABLE_NAME {
        $varType = $VARIABLE_NAME.getText();
        if ($varType.equals("list_double"))
            $varType = "ArrayList<Double>";

        if ($varType.equals("list_boolean"))
            $varType = "ArrayList<Boolean>";

        if ($varType.equals("list_int"))
            $varType = "ArrayList<Integer>";

        if ($varType.equals("list_string"))
            $varType = "ArrayList<String>";

        $paramJavaTypes.add($varType);
      } VARIABLE_NAME {
	        $variableParamNames.add($VARIABLE_NAME.getText());
          $varTypeAndName.add($varType + " " + $VARIABLE_NAME.getText());
        $s = "";
        for(int i=0; i< $varTypeAndName.size(); i++) {
          if(i==($varTypeAndName.size()-1)) {
            $s += $varTypeAndName.get(i);
          } else {
            $s += $varTypeAndName.get(i) + ", ";
          }
        }
      }
		)*
	)? ')' '{' { 
    if(doesFunctionExist($name)) {
      error($n, "Error: function " + $name + "already Exists");
    } else {
	    setMainScope($name);
      for(int i = 0; i < $variableParamNames.size(); i++) {
        String varName = $variableParamNames.get(i);
        String type = $paramJavaTypes.get(i);
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
          createVariable(varName, "<FUNCTION_PARAM>", type);
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
      $arity = $variableParamNames.size();
      createFunction($name, $arity, $doesReturn, $returnType);
      if ($arity > 0) {
        // addCodeLine("public static " + $returnType + " " + $name + "(" + $s + ") {"); // }
      } else {
        // addCodeLine("public static " + $returnType + " " + $name + "() {"); // }
      } 
    }
    
} (
		statement
		| ('define') {
      error($n, "Error can't define function in a function");
    }
	)* '}' {
	  //$arity = $variableParamNames.size();
    //createFunction($name, $arity, $doesReturn);
    functionList.add(getFunction($name));
    //{
    // addCodeLine("}");
    isFunctionReturning = -1;
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

      String paramString ="";
	    if($arity >= 1) {
	        paramString = $params.get(0);
          for(int i = 1; i<$arity; i++){
            paramString += "," + $params.get(i);
          }
      }
      $code = $n.getText() + "(" +paramString + ");";
      $value = $n.getText() + "(" +paramString + ")";
      $asText = $n.getText() + "(" +paramString + ")";
        if($isAssignment) {
	        Identifier ID = getVariable($variable.getText());
            if(ID == null) {
              ID = createVariable($variable.getText(), $code, $funType);
              $code = $funType + " " + ID.id + "=" + $code;
            } else {     
              $code = ID.id + "=" + $code;
        }
      }
        // addCodeLine($code);
    }
  };

input: input_decimal | input_string | input_number;

input_string:
	'input string ' a = VARIABLE_NAME {
	    // addCodeLine($a.getText()+"=___protected___in___.nextLine();");
};
input_number:
	'input number ' a = VARIABLE_NAME {
	    // addCodeLine($a.getText()+"=___protected___in___.nextInt();");
};
input_decimal:
	'input decimal ' a = VARIABLE_NAME {
	    // addCodeLine($a.getText()+"=___protected___in___.nextDouble();");

};

printType
	returns[Boolean hasKnownValue, String value, String code]:
	INT {
    $hasKnownValue = true; 
    $value = $INT.getText();
	  $code = "System.out.println(" + $value + ");";
  }
	| DECIMAL {$hasKnownValue = true; 
  $value = $DECIMAL.getText();
		  $code = "System.out.println(" + $value + ");";
  }
	| STRING {$hasKnownValue = true; 
  $value = $STRING.getText();
		  $code = "System.out.println("+$value+");";
    }
	| VARIABLE_NAME {
        String id = $VARIABLE_NAME.getText();
        used.add(id);
	      $value=id;
        // If we're in the middle of first assignment to VARIABLE_NAME (self-reference):
        if (!doesVariableExist(id)) {
          // General use-before-assign.
          error($VARIABLE_NAME, "use of variable '" + id + "' before assignment");
        } else{
            $code = "System.out.println(" + id + ");";
        }
        $hasKnownValue = false;
      }
	| expr {
          $hasKnownValue = true; 
          $value = String.valueOf($expr.value); 
          $code = "System.out.println("+String.valueOf($expr.value)+");";
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
    if($inline) {
	      // addCodeLine("System.out.print("+ $v.value + ");");
    } else {
	      // addCodeLine("System.out.println("+ $v.value + ");");
    }

	    addPrintLine($v.value);
  };

varExprOrType
	returns[String asText]:
	(t = VARIABLE_NAME | t = STRING | t = BOOL) {
    $asText=$t.getText();
  }
	| e = expr {
	    $asText = $e.exprString;
  }
	| f = functionCall {
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