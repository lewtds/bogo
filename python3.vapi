

[CCode (cheader_filename = "Python.h")]
namespace Python {
    [CCode (cname = "PyObject",
			has_type_id = false,
			ref_function = "Py_IncRef",
			ref_function_void = true,
			unref_function = "Py_DecRef")]
	[Compact]
    public class Object {
		[CCode (cname = "PyObject_GetAttrString")]
		public Object get_attr_string(string attr_name);

		[CCode (cname = "PyObject_CallObject")]
		public Object call(Object args);

		[CCode (cname = "Py_BuildValue")]
		public static Object build_value(string format, ...);
    }

	[CCode (cname = "PyObject")]
	public class Tuple : Object {
		[CCode (cname = "PyTuple_New")]
		public static Tuple new(int length);

		[CCode (cname = "PyTuple_SetItem")]
		public int set_item(int pos, owned Object value);
	}
	
	[CCode (cname="Py_Initialize")]
	public void initialize();

	[CCode (cname="Py_InitializeEx")]
	public void initialize_ex(int initsigs);

	[CCode (cname = "Py_SetProgramName")]
	public void set_program_name(uint16* name);

	[CCode (cname = "PyRun_SimpleString")]
	public int run_simple_string(string command);

	[CCode (cname = "PyRun_String")]
	public Object run_string(string str, int start, Object globals, Object locals);

	[CCode (cname = "Py_Finalize")]
	public void finalize();

	[CCode (cname = "PyObject")]
	public class Bytes : Object {

		[CCode (cname = "PyBytes_FromString")]
		public static Bytes from_string(string from);

		[CCode (cname = "PyBytes_AsString")]
		public unowned string as_string();
	}


	[CCode (cname = "PyObject")]
	public class Unicode : Object {
		[CCode (cname = "PyUnicode_FromString")]
		public static Unicode from_string(string u);

		[CCode (cname = "PyUnicode_AsUTF8")]
		public unowned string as_utf8();

		[CCode (cname = "PyUnicode_AsUTF8String")]
		public Bytes as_utf8_string();
	}

	namespace Import {
		[CCode (cname = "PyImport_Import")]
		public Object import(Object name);

		[CCode (cname = "PyImport_ImportModule")]
		public Object import_module(string name);
	}
}
