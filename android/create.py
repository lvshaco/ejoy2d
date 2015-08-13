import sys
import os
if __name__ == "__main__":
    name = sys.argv[1] 
    f = open("AndroidManifest.xml.def", "r")
    s = f.read()
    s = s.replace("com.XXX.XXX", "com.lvshaco.%s"%name)
    f.close()
    f = open("AndroidManifest.xml", "w")
    f.write(s) 
    f.close()

    os.system("cp src/com/example/testej2d/MyActivity.java.def MyActivity.java")
