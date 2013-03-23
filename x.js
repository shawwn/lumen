current_target="js";current_language="js";function error(msg){throw(msg);}function type(x){return(typeof(x));}function array_length(arr){return(arr.length);}function array_sub(arr,from,upto){return(arr.slice(from,upto));}function array_push(arr,x){arr[array_length(arr)]=x;}function string_length(str){return(str.length);}function string_ref(str,n){return(str.charAt(n));}function string_sub(str,from,upto){return(str.substring(from,upto));}function string_find(str,pattern,start){{var i=str.indexOf(pattern,start);return(((i>0)&&i));}}fs=require("fs");function read_file(filename){return(fs.readFileSync(filename,"utf8"));}function write_file(filename,data){fs.writeFileSync(filename,data,"utf8");}function print(x){console.log(x);}function exit(code){process.exit(code);}function is_string(x){return((type(x)=="string"));}function is_number(x){return((type(x)=="number"));}function is_boolean(x){return((type(x)=="boolean"));}function is_composite(x){return((type(x)=="object"));}function is_atom(x){return(!(is_composite(x)));}function is_table(x){return((is_composite(x)&&(x[0]==undefined)));}function is_array(x){return((is_composite(x)&&!((x[0]==undefined))));}function parse_number(str){{var n=parseFloat(str);if(!(isNaN(n))){return(n);}}}function to_string(x){if((x==undefined)){return("nil");}else if(is_boolean(x)){return(((x&&"true")||"false"));}else if(is_atom(x)){return((x+""));}else{var str="[";var i=0;while((i<array_length(x))){var y=x[i];str=(str+to_string(y));if((i<(array_length(x)-1))){str=(str+" ");}i=(i+1);}return((str+"]"));}}delimiters={};delimiters["("]=true;delimiters[")"]=true;delimiters[";"]=true;delimiters["\n"]=true;whitespace={};whitespace[" "]=true;whitespace["\t"]=true;whitespace["\n"]=true;eof={};function make_stream(str){var s={};s.pos=0;s.string=str;s.length=string_length(str);return(s);}function peek_char(s){return((((s.pos<s.length)&&string_ref(s.string,s.pos))||eof));}function read_char(s){var c=peek_char(s);if(c){s.pos=(s.pos+1);return(c);}}function skip_non_code(s){while(true){var c=peek_char(s);if(!(c)){break;}else if(whitespace[c]){read_char(s);}else if((c==";")){while((c&&!((c=="\n")))){c=read_char(s);}skip_non_code(s);}else{break;}}}function read_atom(s){var str="";while(true){var c=peek_char(s);if((c&&(!(whitespace[c])&&!(delimiters[c])))){str=(str+c);read_char(s);}else{break;}}var n=parse_number(str);return((((n==undefined)&&str)||n));}function read_list(s){read_char(s);var l=[];while(true){skip_non_code(s);var c=peek_char(s);if((c&&!((c==")")))){array_push(l,read(s));}else if(c){read_char(s);break;}else{error(("Expected ) at "+s.pos));}}return(l);}function read_string(s){read_char(s);var str="\"";while(true){var c=peek_char(s);if((c&&!((c=="\"")))){if((c=="\\")){str=(str+read_char(s));}str=(str+read_char(s));}else if(c){read_char(s);break;}else{error(("Expected \" at "+s.pos));}}return((str+"\""));}function read_quote(s){read_char(s);return(["quote",read(s)]);}function read_unquote(s){read_char(s);return(["unquote",read(s)]);}function read(s){skip_non_code(s);var c=peek_char(s);if((c==eof)){return(c);}else if((c=="(")){return(read_list(s));}else if((c==")")){error(("Unexpected ) at "+s.pos));}else if((c=="\"")){return(read_string(s));}else if((c=="'")){return(read_quote(s));}else if((c==",")){return(read_unquote(s));}else{return(read_atom(s));}}operators={};function define_operators(){operators["+"]="+";operators["-"]="-";operators["<"]="<";operators[">"]=">";operators["<="]="<=";operators[">="]=">=";operators["="]="==";operators["and"]=(((current_target=="js")&&"&&")||" and ");operators["or"]=(((current_target=="js")&&"||")||" or ");operators["cat"]=(((current_target=="js")&&"+")||"..");}special={};function define_special(){special["do"]=compile_do;special["set"]=compile_set;special["get"]=compile_get;special["dot"]=compile_dot;special["not"]=compile_not;special["if"]=compile_if;special["function"]=compile_function;special["local"]=compile_local;special["while"]=compile_while;special["list"]=compile_list;special["quote"]=compile_quote;}macros={};function is_call(form){return(is_string(form[0]));}function is_operator(form){return(!((operators[form[0]]==undefined)));}function is_special(form){return(!((special[form[0]]==undefined)));}function is_macro_call(form){return(!((macros[form[0]]==undefined)));}function is_macro_definition(form){return((form[0]=="macro"));}function terminator(is_stmt){return(((is_stmt&&";")||""));}function compile_args(forms){var i=0;var str="(";while((i<array_length(forms))){str=(str+compile(forms[i],false));if((i<(array_length(forms)-1))){str=(str+",");}i=(i+1);}return((str+")"));}function compile_body(forms){var i=0;var str=(((current_target=="js")&&"{")||"");while((i<array_length(forms))){str=(str+compile(forms[i],true));i=(i+1);}return((((current_target=="js")&&(str+"}"))||str));}function normalize(id){var id2="";var i=0;while((i<string_length(id))){var c=string_ref(id,i);if((c=="-")){c="_";}id2=(id2+c);i=(i+1);}var last=(string_length(id)-1);if((string_ref(id,last)=="?")){var name=string_sub(id2,0,last);id2=("is_"+name);}return(id2);}function compile_atom(form,is_stmt){if((form=="[]")){return((((current_target=="lua")&&"{}")||"[]"));}else if((form=="nil")){return((((current_target=="js")&&"undefined")||"nil"));}else if((is_string(form)&&!((string_ref(form,0)=="\"")))){return((normalize(form)+terminator(is_stmt)));}else{return(to_string(form));}}function compile_call(form,is_stmt){var fn=compile(form[0],false);var args=compile_args(array_sub(form,1));return((fn+args+terminator(is_stmt)));}function compile_operator(form){var i=1;var str="(";var op=operators[form[0]];while((i<array_length(form))){str=(str+compile(form[i],false));if((i<(array_length(form)-1))){str=(str+op);}i=(i+1);}return((str+")"));}function compile_do(forms,is_stmt){if(!(is_stmt)){error("Cannot compile DO as an expression");}var body=compile_body(forms);return((((current_target=="js")&&body)||("do "+body+" end ")));}function compile_set(form,is_stmt){if(!(is_stmt)){error("Cannot compile assignment as an expression");}if((array_length(form)<2)){error("Missing right-hand side in assignment");}var lh=compile(form[0],false);var rh=compile(form[1],false);return((lh+"="+rh+terminator(true)));}function compile_branch(branch,is_first,is_last){var condition=compile(branch[0],false);var body=compile_body(array_sub(branch,1));var tr="";if((is_last&&(current_target=="lua"))){tr=" end ";}if(is_first){return((((current_target=="js")&&("if("+condition+")"+body))||("if "+condition+" then "+body+tr)));}else if((is_last&&(condition=="true"))){return((((current_target=="js")&&("else"+body))||(" else "+body+" end ")));}else{return((((current_target=="js")&&("else if("+condition+")"+body))||(" elseif "+condition+" then "+body+tr)));}}function compile_if(form,is_stmt){if(!(is_stmt)){error("Cannot compile IF as an expression");}var i=0;var str="";while((i<array_length(form))){var is_last=(i==(array_length(form)-1));var is_first=(i==0);var branch=compile_branch(form[i],is_first,is_last);str=(str+branch);i=(i+1);}return(str);}function compile_function(form,is_stmt){var name=compile(form[0]);var args=compile_args(form[1]);var body=compile_body(array_sub(form,2));var tr=(((current_target=="lua")&&" end ")||"");return(("function "+name+args+body+tr));}function compile_get(form,is_stmt){var object=compile(form[0],false);var key=compile(form[1],false);return((object+"["+key+"]"+terminator(is_stmt)));}function compile_dot(form,is_stmt){var object=compile(form[0],false);var key=form[1];return((object+"."+key+terminator(is_stmt)));}function compile_not(form,is_stmt){var expr=compile(form[0],false);var tr=terminator(is_stmt);return((((current_target=="js")&&("!("+expr+")"+tr))||("(not "+expr+")"+tr)));}function compile_local(form,is_stmt){if(!(is_stmt)){error("Cannot compile local variable declaration as an expression");}var lh=compile(form[0]);var tr=terminator(true);var keyword=(((current_target=="js")&&"var ")||"local ");if((form[1]==undefined)){return((keyword+lh+tr));}else{var rh=compile(form[1],false);return((keyword+lh+"="+rh+tr));}}function compile_while(form,is_stmt){if(!(is_stmt)){error("Cannot compile WHILE as an expression");}var condition=compile(form[0],false);var body=compile_body(array_sub(form,1));return((((current_target=="js")&&("while("+condition+")"+body))||("while "+condition+" do "+body+" end ")));}function compile_list(forms,is_stmt,is_quoted){if(is_stmt){error("Cannot compile LIST as a statement");}var i=0;var str=(((current_target=="lua")&&"{")||"[");while((i<array_length(forms))){var x=forms[i];var x1=((is_quoted&&quote_form(x))||compile(x,false));if(((i==0)&&(current_target=="lua"))){str=(str+"[0]=");}str=(str+x1);if((i<(array_length(forms)-1))){str=(str+",");}i=(i+1);}return((str+(((current_target=="lua")&&"}")||"]")));}function compile_to_string(form){return(((is_string(form)&&("\""+form+"\""))||to_string(form)));}function quote_form(form){if((is_string(form)&&(string_ref(form,0)=="\""))){return(form);}else if(is_atom(form)){return(compile_to_string(form));}else if((form[0]=="unquote")){return(compile(form[1],false));}else{return(compile_list(form,false,true));}}function compile_quote(forms,is_stmt){if(is_stmt){error("Cannot compile quoted form as a statement");}if((array_length(forms)<1)){error("Must supply at least one argument to QUOTE");}return(quote_form(forms[0]));}function compile_macro(form,is_stmt){if(!(is_stmt)){error("Cannot compile macro definition as an expression");}var tmp=current_target;current_target=current_language;eval(compile_function(form,true));var name=form[0];var register=["set",["get","macros",compile_to_string(name)],name];eval(compile(register,true));current_target=tmp;}function compile(form,is_stmt){if((form==undefined)){return("");}else if(is_atom(form)){return(compile_atom(form,is_stmt));}else if(is_call(form)){if((is_operator(form)&&is_stmt)){error(("Cannot compile operator application as a statement"));}else if(is_operator(form)){return(compile_operator(form));}else if(is_macro_definition(form)){compile_macro(array_sub(form,1),is_stmt);return("");}else if(is_special(form)){var fn=special[form[0]];return(fn(array_sub(form,1),is_stmt));}else if(is_macro_call(form)){var fn=macros[form[0]];var form=fn(array_sub(form,1));return(compile(form,is_stmt));}else{return(compile_call(form,is_stmt));}}else{error(("Unexpected form: "+to_string(form)));}}function compile_file(filename){var form;var output="";var s=make_stream(read_file(filename));while(true){form=read(s);if((form==eof)){break;}output=(output+compile(form,true));}return(output);}function usage(){print("usage: x input [-o output] [-t target]");exit();}args=array_sub(process.argv,2);if((array_length(args)<1)){usage();}input=args[0];output=false;i=1;while((i<array_length(args))){var arg=args[i];if(((arg=="-o")||(arg=="-t"))){if((array_length(args)>(i+1))){i=(i+1);var arg2=args[i];if((arg=="-o")){output=arg2;}else{current_target=arg2;}}else{print("missing argument for",arg);usage();}}else{print("unrecognized option:",arg);usage();}i=(i+1);}if((output==false)){var name=string_sub(input,0,string_find(input,"."));output=(name+"."+current_target);}define_operators();define_special();write_file(output,compile_file(input));