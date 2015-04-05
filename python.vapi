[CCode (cheader_filename = "Python.h")]
namespace Python {
	[CCode (cname="Py_Initialize")]
	public void initialize();

	[CCode (cname = "Py_SetProgramName")]
	public void set_program_name(string name);

	[CCode (cname = "PyRun_SimpleString")]
	public int run_simple_string(string command);

	[CCode (cname = "Py_Finalize")]
	public void finalize();
}