[CCode (cheader_filename = "Python.h")]
namespace Python {
    [CCode (cname = "PyObject",
			has_type_id = false,
			ref_function = "Py_Ref",
			ref_function_void = true,
			unref_function = "Py_DecRef")]
	[Compact]
    public class Object {
    }
	
	[CCode (cname="Py_Initialize")]
	public void initialize();

	[CCode (cname = "Py_SetProgramName")]
	public void set_program_name(string name);

	[CCode (cname = "PyRun_SimpleString")]
	public int run_simple_string(string command);

	[CCode (cname = "PyRun_String")]
	public Object run_string(string str, int start, Object globals, Object locals);

	[CCode (cname = "Py_Finalize")]
	public void finalize();

	[CCode (cname = "PyStringObject")]
	public class String : Object {

		[CCode (cname = "PyString_FromString")]
		public static Object from_string(string from);
	}

	namespace Import {
		[CCode (cname = "PyImport_Import")]
		public Object import(Object name);

		[CCode (cname = "PyImport_ImportModule")]
		public Object import_module(string name);
	}
}