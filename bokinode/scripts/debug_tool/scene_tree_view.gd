extends PanelContainer

# --- Exports ---
@export var enabled: bool = true # このUI自体の表示/非表示を切り替えるフラグ
@export var save_to_file: bool = false # trueの場合、ツリー構造をテキストファイルに保存する
@export var output_file_path: String = "res://scripts/debug_tool/scene_tree.txt" # 保存するファイルパス

# --- Node References ---
# ノード構成を表示するRichTextLabelへの参照
@onready var tree_label: RichTextLabel = $MarginContainer/TreeLabel

# スキャンを開始するルートノード。
# nullの場合は、このノードが追加されたシーンのルートを自動的に取得します。
@export var root_node: Node
# --- Private Variables ---
var _tree_text: String = "" # 生成したツリーテキストを保持する


func _ready() -> void:
	# 等幅フォントを設定してインデントが崩れないようにする
	var font = ThemeDB.get_fallback_font()
	tree_label.add_theme_font_override("normal_font", font)
	tree_label.add_theme_font_size_override("normal_font_size", 14) # フォントサイズを調整

	# enabledフラグがfalseならUIを非表示にする
	if not enabled:
		hide()
		# UIが非表示でもファイル保存は機能させたい場合があるので、ここでreturnしない

	# root_nodeがインスペクターで設定されていなければ、現在のシーンのルートを設定
	if not root_node:
		root_node = get_tree().current_scene

	# ノードツリーを生成して表示
	generate_tree_view()


func generate_tree_view() -> void:
	"""ノードツリーのテキスト表現を生成し、Labelに設定する。"""
	if not root_node:
		_tree_text = "Error: Root node is not set."
		print(_tree_text) # エラーもコンソールに出力
		if enabled:
			tree_label.text = _tree_text
		return

	var output: PackedStringArray
	output.append(root_node.name + " (" + root_node.get_class() + ")")
	
	_build_tree_recursive(root_node, "", output)
	
	_tree_text = "\n".join(output)

	# --- UIへの表示 ---
	if enabled:
		tree_label.text = _tree_text

	# --- コンソールへの出力 ---
	# 以前のprint機能も残しておく
	print("--- Scene Tree View ---")
	print(_tree_text)
	print("-----------------------")

	# --- ファイルへの保存 ---
	if save_to_file:
		_save_text_to_file(_tree_text)


func _save_text_to_file(text: String) -> void:
	"""指定されたパスにテキストを保存する。"""
	var file = FileAccess.open(output_file_path, FileAccess.WRITE)
	if FileAccess.get_open_error() == OK:
		file.store_string(text)
		print("Scene tree saved to: ", output_file_path)
	else:
		printerr("Failed to open file for writing: ", output_file_path)

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
