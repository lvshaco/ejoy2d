notice
======
* 使用cocosstudio界面编辑器编辑生成csd文件
* scene类型、layer类型csd可任意
* node类型如果仅有一个sprite控件则导出成一个单一composite，
否则导出成各个独立control

自定义规则
==========
* sprite名字以[T]结尾则解析为支持touch事件
* label名字以[E]结尾则解析为有边框字体
* listview名字以[数字]结尾则解析为同时显示的item个数
