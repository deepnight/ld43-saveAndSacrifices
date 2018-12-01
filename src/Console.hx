import mt.MLib;

class Console extends h2d.Console {
	public static var ME : Console;
	#if debug
	var flags : Map<String,Bool>;
	#end

	public function new(f:h2d.Font, p:h2d.Object) {
		super(f, p);

		h2d.Console.HIDE_LOG_TIMEOUT = 30;
		ME = this;
		mt.deepnight.Lib.redirectTracesToH2dConsole(this);

		#if debug
		// Console flags
		flags = new Map();
		this.addCommand("set", [{ name:"k", t:AString }], function(k:String) {
			set(k,true);
			log("+ "+k, 0x80FF00);
		});
		this.addCommand("unset", [{ name:"k", t:AString, opt:true } ], function(?k:String) {
			if( k==null ) {
				log("Reset all.",0xFF0000);
				flags = new Map();
			}
			else {
				log("- "+k,0xFF8000);
				set(k,false);
			}
		});
		this.addAlias("+","set");
		this.addAlias("-","unset");
		#end
	}

	#if debug
	public function set(k:String,v) return flags.set(k,v);
	public function has(k:String) return flags.get(k)==true;
	#end
}