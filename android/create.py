import sys
if __name__ == "__main__":
    name = sys.argv[1] 
    f = open("AndroidManifest.xml.def", "r")
    s = f.read()
    s = s.replace("com.XXX.XXX", "com.lvshaco.%s"%name)
    f.close()
    f = open("AndroidManifest.xml", "w")
    f.write(s) 
    f.close()


    f = open("src/com/example/testej2d/MyActivity.java.def", "r")
    s = f.read()
    s = s.replace("XXX.lua", "%s.lua"%name)
    f.close()
    f = open("MyActivity.java", "w")
    f.write(s)
    f.close()
