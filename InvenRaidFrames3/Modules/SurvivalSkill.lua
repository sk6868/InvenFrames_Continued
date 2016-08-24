local _G = _G
local pairs = _G.pairs
local GetTime = _G.GetTime
local UnitBuff = _G.UnitBuff
local IRF3 = _G[...]

-- 직업별 생존기 정의 (*는 타인에게 걸 수 있는 생존기+드워프 석화와 드레나이 나루)
local SL = IRF3.GetSpellName
local skills = {	-- 인벤 유저 "작은풀씨"님 추가 및 수정 사항 적용 (감사합니다) 2013/5/21 http://www.inven.co.kr/board/powerbbs.php?come_idx=17&l=20589
	["WARRIOR"] = { [SL(871)] = "방벽", [SL(12975)] = "최저", [SL(125565)] = "사기", [SL(118038)] = "투혼", [SL(184364)] = "격재", [SL(203524)] = "넬타", [SL(23920)] = "주반", [SL(197690)] = "방태" },
	["ROGUE"] = { [SL(5277)] = "회피", [SL(31224)] = "그망", [SL(1966)] = "교란", [SL(11327)] = "소멸", [SL(199754)] = "반격", [SL(185311)] = "약병" },
	["PALADIN"] = { [SL(642)] = "무적", [SL(498)] = "가호", [SL(31850)] = "헌수", [SL(86659)] = "고대왕", [SL(31821)] = "오라", [SL(190784)] = "군마", [SL(152262)] = "고천", [SL(184662)] = "복수", [SL(205191)] = "눈-눈" },
	["MAGE"] = { [SL(27619)] = "얼방", [SL(32612)] = "투명", [SL(113862)] = "상투", [SL(115610)] = "시보" },
	["HUNTER"] = { [SL(5384)] = "죽척", [SL(186265)] = "거북", [SL(199483)] = "위장술", [SL(53271)] = "주부" },
	["PRIEST"] = { [SL(27827)] = "구원", [SL(47585)] = "분산", [SL(15286)] = "흡선", [SL(586)] = "소실" },
	["DRUID"] = { [SL(61336)] = "생본", [SL(22812)] = "껍질", [SL(192083)] = "우징", [SL(200851)] = "분노", [SL(102558)] = "우르속" },
	["DEATHKNIGHT"] = { [SL(48792)] = "얼인", [SL(55233)] = "흡혈", [SL(81256)] = "춤룬", [SL(48707)] = "대마보", [SL(194679)] = "룬전", [SL(212552)] = "망령", [SL(207319)] = "시체" },
	["SHAMAN"] = { [SL(108271)] = "영혼", [SL(108281)] = "고인", [SL(210918)] = "에테" },
	["WARLOCK"] = { [SL(104773)] = "결의", [SL(108416)] = "서약" },
	["MONK"] = { [SL(120954)] = "강화주", [SL(122783)] = "마해", [SL(125174)] = "업보", [SL(201318)] = "비약", [SL(122278)] = "해악" },
	["DEMONHUNTER"] = { [SL(187827)] = "탈태", [SL(218256)] = "수호물", [SL(196555)] = "황천", [SL(203720)] = "쐐기", [SL(198569)] = "흐릿"},
	["*"] = { [SL(1022)] = "보축", [SL(47788)] = "수호", [SL(20594)] = "석화", [SL(59544)] = "나루", [SL(33206)] = "고억", [SL(6940)] = "희축", [SL(102342)] = "무껍", [SL(29166)] = "자극", [SL(116849)] = "고치", [SL(156428)] = "힘", [SL(156430)] = "유연성", [SL(156423)] = "민첩", [SL(156426)] = "지능", [SL(228049)] = "여왕", [SL(204018)] = "주축", [SL(188029)] = "방어도", [SL(188027)] = "은총", [SL(188028)] = "전쟁" },
}
local checkSpellID = {
	[SL(86659)] = 86659, [SL(74001)] = 74001,-- 고대 왕의 수호자(보호 특성), 전투 준비(전장 버프와 겹침)
}
local ignoreEndTime = { [SL(11327)] = true, [SL(5384)] = true }
for _, v in pairs(skills) do
	v[""] = nil
end
ignoreEndTime[""] = nil
checkSpellID[""] = nil

local function findSkill(unit, lookup)
	for spell, newText in pairs(lookup) do
		local name, _, _, _, _, _, endTime, _, _, _, spellId = UnitBuff(unit, spell)
		if name then
			if checkSpellID[name] then
				if checkSpellID[name] == spellId then
					return newText, (not ignoreEndTime[spell] and endTime and endTime > 0) and endTime
				end
			else
				return newText, (not ignoreEndTime[spell] and endTime and endTime > 0) and endTime
			end
		end
	end
	return nil
end

local function checkSkill(unit, class)
	-- 타인에게 걸 수 있는 생존기 체크
	local name, endTime = findSkill(unit, skills["*"])
	if not name and skills[class] then
		name, endTime = findSkill(unit, skills[class])
	end
	return name, endTime
end

local function survivalSkillOnUpdate(self)
	if self.survivalSkillEndTime then
		self.survivalSkillTimeLeft = (":%d"):format(self.survivalSkillEndTime - GetTime() + 0.5)
	end
	InvenRaidFrames3Member_UpdateLostHealth(self)--이름 프레임 업데이트
end

function InvenRaidFrames3Member_UpdateSurvivalSkill(self)
	if IRF3.db.units.useSurvivalSkill then
		self.survivalSkill, self.survivalSkillEndTime = checkSkill(self.displayedUnit, self.class)
		self.survivalSkillTimeLeft = self.survivalSkillEndTime and (self.survivalSkillEndTime - GetTime()) or ""
		if not self.survivalticker then
			self.survivalticker = C_Timer.NewTicker(0.5, function() survivalSkillOnUpdate(self) end)
		end
		survivalSkillOnUpdate(self)
	else
		if self.survivalticker then
			self.survivalticker:Cancel()
			self.survivalticker = nil
		end
		self.survivalSkill, self.survivalSkillEndTime, self.survivalSkillTimeLeft = nil, nil, nil
	end
	InvenRaidFrames3Member_UpdateLostHealth(self)--이름 프레임 업데이트
end
