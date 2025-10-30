# file_lister.gd
extends Node

# このスクリプトがアタッチされたノードがツリーに追加された時に実行される
func _ready():
	print("--- Project File Structure ---")
	# "res://" はGodotプロジェクトのルートディレクトリを指す
	print_directory_tree("res://")
	print("------------------------------")
	# スクリプトの役目が終わったらキューから削除する（任意）
	queue_free()


# 指定されたパスのディレクトリツリーを再帰的に表示する関数
func print_directory_tree(path: String, indent: String = ""):
	# 無視するディレクトリのリスト
	var ignored_dirs = [".godot", ".import"]

	# DirAccessを使ってディレクトリを開く
	var dir = DirAccess.open(path)
	if dir:
		# ディレクトリ内のスキャンを開始
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var files = []
		
		# ファイルがなくなるまでループ
		while file_name != "":
			# "." と ".." は現在のディレクトリと親ディレクトリを指すので無視する
			if file_name != "." and file_name != "..":
				# 現在の項目がディレクトリかどうかをチェック
				if dir.current_is_dir():
					# 無視リストに含まれていないディレクトリのみ処理
					if not ignored_dirs.has(file_name):
						files.append({"name": file_name, "is_dir": true})
				else:
					files.append({"name": file_name, "is_dir": false})
			
			# 次のファイルへ
			file_name = dir.get_next()
		
		# スキャンを終了（推奨）
		dir.list_dir_end()

		# 取得したファイルとディレクトリを処理
		for i in range(files.size()):
			var item = files[i]
			var is_last = (i == files.size() - 1)
			var prefix = indent + ("└─ " if is_last else "├─ ")
			var child_indent = indent + ("   " if is_last else "│  ")

			if item.is_dir:
				print(prefix + item.name + "/")
				print_directory_tree(path.path_join(item.name), child_indent)
			else:
				print(prefix + item.name)
	else:
		printerr("An error occurred when trying to access the path: ", path)
