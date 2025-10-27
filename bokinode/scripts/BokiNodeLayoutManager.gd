extends Node

const BokiNodeScene = preload("res://scenes/BokiNode.tscn")

# ノードを生成し、レイアウトし、その辞書を返す
func setup_and_layout_nodes(container: Node) -> Dictionary:
	print("--- [LayoutManager] setup_and_layout_nodes: ノードのセットアップを開始 ---")
	
	var boki_nodes: Dictionary = {}
	
	# 勘定科目の種類ごとにノードを整理するための辞書
	var categorized_nodes: Dictionary = {
		Account.Type.ASSET: [],
		Account.Type.LIABILITY: [],
		Account.Type.EQUITY: [],
		Account.Type.REVENUE: [],
		Account.Type.EXPENSE: [],
	}

	# Ledger.accounts辞書の値（Accountリソース）を一つずつ取り出す
	for account_data in Ledger.accounts.values():
		var node_instance = BokiNodeScene.instantiate()
		container.add_child(node_instance)
		# Accountリソースが持つ `id` をキーとして、ノードのインスタンスを辞書に登録
		boki_nodes[account_data.id] = node_instance
		print("  - Setting up node for: '", account_data.name, "' with ID: '", account_data.id, "'")
		node_instance.setup(account_data)

		categorized_nodes[account_data.account_type].append(node_instance)

	# 簿記のレイアウトに合わせて配置（左側に資産、右側にその他）
	_layout_nodes(categorized_nodes[Account.Type.ASSET], Vector2(150, 200))
	_layout_nodes(categorized_nodes[Account.Type.LIABILITY], Vector2(500, 150))
	_layout_nodes(categorized_nodes[Account.Type.EQUITY], Vector2(500, 300))
	_layout_nodes(categorized_nodes[Account.Type.REVENUE], Vector2(850, 150))
	_layout_nodes(categorized_nodes[Account.Type.EXPENSE], Vector2(850, 300))
	print("--- [LayoutManager] setup_and_layout_nodes: ノードのセットアップ完了 ---")
	return boki_nodes

func _layout_nodes(nodes: Array, start_pos: Vector2):
	for i in range(nodes.size()):
		nodes[i].position = start_pos + Vector2(0, i * 120)
