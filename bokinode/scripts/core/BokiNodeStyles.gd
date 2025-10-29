# BokiNodeStyles.gd
# BokiNodeの色など、スタイルに関する定数を定義します。
extends Node


# 勘定科目の種類と、それに対応するBokiNodeの背景色を定義します。
var NODE_COLORS = {
	Account.Type.ASSET: Color.DODGER_BLUE,
	Account.Type.LIABILITY: Color.INDIAN_RED,
	Account.Type.EQUITY: Color("#9370db"), # MEDIUM_PURPLE
	Account.Type.REVENUE: Color.SEA_GREEN,
	Account.Type.EXPENSE: Color.GOLD,
}
