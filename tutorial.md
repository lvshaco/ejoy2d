## new project

1. clone git@github.com:lvshaco/ejoy2d.git or https://github.com/lvshaco/ejoy2d.git
2. cd ejoy2d
3. ./shaco-foot fork *name*
4. cd ../*name* (enter your project)

## android

1. **MyActivity.java**: the default android start script is main.lua, you can change the config, just replace the string `main.lua` to other in MyActivity.java
2. **AndroidManifest.xml**: alter it will change android application behavior
3. **./shaco-foot android**: deploy

## ui
#### use cocosstudio to edit ui, it export csd file

1. open cocosstudio, create new project, name is `ui`, path is `your project path`
2. new csd, the type layer/scene/node is allow, but node type csd will export contorl alone except only one control will export to composite
3. new image folder, the name is `image`, the real path is `project/ui/cocosstudio/image`

#### control type

- sprite: name endswith `[T]` support touch event
- label:  name endswith `[E]` the font has edge
- listview: name endswith `[number]` the number is item show count

