import mt.data.GetText;

class Lang {
    public static var CUR = "??";
    // public static var t : GetText;

    public static function init(lid:String) {
        CUR = lid;
        // t = new GetText();
    }

    public static function untranslated(str:Dynamic) : LocaleString {
        return cast str;
        // return t.untranslated(str);
    }
}