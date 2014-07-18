require 'rubygems'
require 'roo'
require 'csv'
require 'json'
require './function.rb' # 独自の関数

CSVNAME = "dormeal.csv"

# 変換 xlsx => csv

file2convert = Dir.glob("*.xlsx")[0]
puts file2convert + "をCSVに変換します"
book = Roo::Excelx.new(file2convert)
book.default_sheet = book.sheets.first
book.to_csv(CSVNAME)
puts "変換に成功しました"

# 加工

# 空白を削る

options = { # CSVファイルを読み込むときのオプション
	:col_sep => ',',
	:skip_blanks => true,
	:headers => findDaysRow
}
file = CSV.read(CSVNAME, options)

nthRowWithVal(file.to_a, "区分").times do
	file.delete(0)
end

# 一番左の列が空白なので削る
file.by_col!
file.delete(0)
file.by_row!

# 空白を除いたCSV::TableをArrayに変換
arr = file.to_a

# 日付を配列に格納
days = []
1.step(getLengthOfCols(file), 3) do |i|
	header = file.headers
	if (header[i] != nil && header[i] != ' ') then
		days << header[i]
	end
end

# すべてのデータを格納するハッシュを作成
data = Hash.new

# すべてのメニューを格納する配列を作成
menu = Array.new(days.length)

# 朝昼夕と合計が何行目から始まるかを格納する配列		
mealFirstRow = [nthRowWithVal(arr, '朝食'),
			nthRowWithVal(arr, '昼食'),
			nthRowWithVal(arr, "夕食"),
			nthRowWithVal(arr, "合計")]
dayHeader = 1

# 1日単位のループ
for i in 0...menu.length do
	meal = []

	# 食事単位のループ
	3.times do |i|
		meal[i] = Hash.new
		dishes = []
		j = 0
		while arr[mealFirstRow[i] + j][dayHeader + 2] != nil && arr[mealFirstRow[i] + j][dayHeader + 2].rindex("KC") != nil
			anotherMenu = [arr[mealFirstRow[i] + j][dayHeader], arr[mealFirstRow[i] + j][dayHeader+2].delete("KC").to_i]
			dishes += Array.new(2)
			dishes[j] = anotherMenu
			j += 1
		end
		dishes.compact!
		
		while arr[mealFirstRow[i] + j][dayHeader] == " " || arr[mealFirstRow[i] + j][dayHeader] == nil
			j += 1
		end
		# nutritionに栄養情報を格納する
		puts arr[mealFirstRow[i] + j][dayHeader].to_s
		nutrition = getNutrition(arr[mealFirstRow[i] + j][dayHeader])
		
		meal[i] = {"dishes" => dishes, "nutrition" => nutrition}
	end

	dayMenu = {"breakfast" => meal[0], "lunch" => meal[1], "dinner" => meal[2]}
	
	# nutritionに1日の栄養情報を格納する
	nutrition = getNutrition(arr[mealFirstRow[3]][dayHeader])
	menu[i] = {"date" => days[i], "month" => getMonth(days[i]), "day" => getDay(days[i]), "dow" => getDayOfWeek(days[i]), "daily_menu" => dayMenu, "daily_nutrition" => nutrition}
	
	dayHeader += 3
end

#dataにデータを格納する
data = {"menu" => menu}

# JSONに変換した結果を表示
print JSON.generate(data)

# JSONファイル(menu.json)を出力
open("menu.json", "w") do |io|
	JSON.dump(data, io)
end
