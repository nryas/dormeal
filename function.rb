# 日付が書かれた列数を返す
def findDaysRow
	CSV.foreach(CSVNAME) do |row|
		if row[1] == "区分" then
			return row
		end
	end
end

# 列の長さを返す
def getLengthOfCols(table)
	table.by_col!
	numOfCols = table.length
	table.by_row!
	return numOfCols
end

# 指定した値がはじめに見つかる列の数を返す．見つからない場合は-1を返す．
def nthRowWithVal(data, val)
	count = 0
	data.each do |row|
		row.each do |elem|
			if elem == val then
				return count
			end
		end
		count += 1
	end
	return -1
end

# 月を返す
def getMonth(date)
split = date.split("/")
month = split[0].to_i
return month
end

# 日を返す
def getDay(date)
split = date.split("/")
splitRight = split[1]
day = splitRight.split("(")[0].to_i
return day
end

# 曜日の漢字を返す
def getDayOfWeek(date)
dow = -1
kanjiArr = %w{月 火 水 木 金 土 日}
	kanjiArr.each do |kanji|
		if date[kanji]!= nil
			dow = kanji
		end
	end
	return dow
end

# 栄養のハッシュを返す
def getNutrition(str)
	natrition = Hash.new
	items = %w{kcal protein fat cabs salt}
	split = str.split(/\D*[ ]\D*/)
	for i in 0...split.length do
		val = (i!=4) ? split[i].to_i : split[i].to_f
		natrition.store(items[i],val)
	end
	return natrition
end
