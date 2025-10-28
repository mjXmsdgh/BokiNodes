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
	# DirAccessを使ってディレクトリを開く
	var dir = DirAccess.open(path)
	if dir:
		# ディレクトリ内のスキャンを開始
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		# ファイルがなくなるまでループ
		while file_name != "":
			# "." と ".." は現在のディレクトリと親ディレクトリを指すので無視する
			if file_name != "." and file_name != "..":
				# 現在の項目がディレクトリかどうかをチェック
				if dir.current_is_dir():
					# ディレクトリの場合
					print(indent + "└─ " + file_name + "/")
					# 再帰呼び出しでサブディレクトリの中身も表示（インデントを増やす）
					print_directory_tree(path.path_join(file_name), indent + "    ")
				else:
					# ファイルの場合
					print(indent + "   - " + file_name)
			
			# 次のファイルへ
			file_name = dir.get_next()
		
		# スキャンを終了（推奨）
		dir.list_dir_end()
	else:
		printerr("An error occurred when trying to access the path: ", path)
