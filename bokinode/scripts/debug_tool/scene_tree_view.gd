extends PanelContainer

# ノード構成を表示するRichTextLabelへの参照
@onready var tree_label: RichTextLabel = $MarginContainer/TreeLabel

# スキャンを開始するルートノード。
# nullの場合は、このノードが追加されたシーンのルートを自動的に取得します。
@export var root_node: Node


func _ready() -> void:
	# 等幅フォントを設定してインデントが崩れないようにする
	var font = ThemeDB.get_fallback_font()
	tree_label.add_theme_font_override("normal_font", font)
	tree_label.add_theme_font_size_override("normal_font_size", 14) # フォントサイズを調整

	# root_nodeがインスペクターで設定されていなければ、現在のシーンのルートを設定
	if not root_node:
		root_node = get_tree().current_scene

	# ノードツリーを生成して表示
	generate_tree_view()


func generate_tree_view() -> void:
	"""ノードツリーのテキスト表現を生成し、Labelに設定する。"""
	if not root_node:
		tree_label.text = "Error: Root node is not set."
		return

	var output: PackedStringArray
	output.append(root_node.name + " (" + root_node.get_class() + ")")
	
	_build_tree_recursive(root_node, "", output)
	
	tree_label.text = "\n".join(output)


func _build_tree_recursive(node: Node, prefix: String, output: PackedStringArray) -> void:
	"""ノードを再帰的にたどり、ツリー構造を構築する。"""
	var children = node.get_children()
	var i = 0
	for child in children:
		var is_last = (i == children.size() - 1)
		
		var line_prefix = prefix
		var child_prefix = prefix
		
		if is_last:
			line_prefix += "└─ "
			child_prefix += "   "
		else:
			line_prefix += "├─ "
			child_prefix += "│  "
		
		var node_info = child.name + " (" + child.get_class() + ")"
		output.append(line_prefix + node_info)
		
		# 再帰的に子ノードを処理
		_build_tree_recursive(child, child_prefix, output)
		
		i += 1