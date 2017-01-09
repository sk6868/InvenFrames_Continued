local _G = _G
local IRF3 = _G[...]
local GetTime = _G.GetTime
local UnitBuff = _G.UnitBuff
local UnitDebuff = _G.UnitDebuff
local PlaySoundFile = _G.PlaySoundFile
local SM = LibStub("LibSharedMedia-3.0")
local LRD = LibStub("LibRealDispel-1.0")

local ignoreAuraId = {}
local ignoreAuraName = {}
local bossAuraId = {}
local bossAuraName = {}

IRF3.ignoreAura = {
	[6788] = true, [8326] = true, [11196] = true, [15822] = true, [21163] = true,
	[24360] = true, [24755] = true, [25771] = true, [26004] = true, [26013] = true,
	[26680] = true, [28169] = true, [28504] = true, [29232] = true, [30108] = true,
	[30529] = true, [36032] = true, [36893] = true, [36900] = true, [36901] = true,
	[40880] = true, [40882] = true, [40883] = true, [40891] = true, [40896] = true,
	[40897] = true, [41292] = true, [41337] = true, [41350] = true, [41425] = true,
	[43681] = true, [55711] = true, [57723] = true, [57724] = true, [64805] = true,
	[64808] = true, [64809] = true, [64810] = true, [64811] = true, [64812] = true,
	[64813] = true, [64814] = true, [64815] = true, [64816] = true, [69127] = true,
	[69438] = true, [70402] = true, [71328] = true, [72144] = true, [72145] = true,
	[80354] = true, [95223] = true, [89798] = true, [96328] = true, [96325] = true,
	[96326] = true, [95809] = true, [36895] = true, [71041] = true, [122835] = true,
	[173660] = true, [173649] = true, [173657] = true, [173658] = true, [173976] = true,
	[173661] = true, [174524] = true, [173659] = true,

}
IRF3.bossAura = {
	[605] = true, [8399] = true, [11433] = true, [12294] = true, [17140] = true,
	[29879] = true, [30115] = true, [30756] = true, [31306] = true, [31344] = true,
	[31347] = true, [31943] = true, [31972] = true, [32779] = true, [37027] = true,
	[37676] = true, [38049] = true, [38246] = true, [39837] = true, [40239] = true,
	[40251] = true, [40327] = true, [40481] = true, [40508] = true, [40585] = true,
	[40594] = true, [40869] = true, [40932] = true, [41032] = true, [41472] = true,
	[41917] = true, [42005] = true, [42783] = true, [43095] = true, [43149] = true,
	[43657] = true, [44811] = true, [44867] = true, [45141] = true, [45150] = true,
	[45230] = true, [45256] = true, [45348] = true, [45641] = true,
	[45661] = true, [45737] = true, [45996] = true, [46469] = true, [46771] = true,
	[51121] = true, [55249] = true, [55550] = true, [58517] = true, [59265] = true,
	[59847] = true, [61888] = true, [61903] = true, [61968] = true, [61969] = true,
	[62130] = true, [62331] = true, [62526] = true, [62532] = true, [62589] = true,
	[62661] = true, [62717] = true, [63018] = true, [63276] = true, [63355] = true,
	[63498] = true, [63666] = true, [63830] = true, [64234] = true, [64292] = true,
	[64396] = true, [64705] = true, [64771] = true, [65121] = true, [65598] = true,
	[66013] = true, [66869] = true, [67574] = true, [69065] = true, [69200] = true,
	[69240] = true, [69278] = true, [69409] = true, [69483] = true, [69674] = true,
	[70126] = true, [70337] = true, [70447] = true, [70541] = true, [70672] = true,
	[70867] = true, [71204] = true, [71289] = true, [71330] = true, [71340] = true,
	[72004] = true, [72219] = true, [72293] = true, [72385] = true, [72408] = true,
	[72451] = true, [90098] = true, [79888] = true, [80094] = true, [92023] = true,
	[79501] = true, [77760] = true, [77786] = true, [78075] = true, [78092] = true,
	[89666] = true, [86788] = true, [86013] = true, [82762] = true,
	-- 불의 땅
	[49026] = true, [99837] = true, [99936] = true, [99262] = true, [100094] = true,
	[99263] = true, [99516] = true, [98450] = true, [99399] = true, [100238] = true,
	[100460] = true,
	-- 용의 영혼, 판다리아의 안개, 드레노어의 전쟁군주, 기타등등
	[116278] = true, [120629] = true, [136228] = true, [156214] = true, [145568] = true,
	[158605] = true, [159179] = true, [146589] = true, [172886] = true, [180313] = true,
	[150032] = true, [143434] = true, [140661] = true, [147068] = true, [140502] = true,
	[156631] = true, [136295] = true, [188666] = true, [153795] = true, [162497] = true,
	[143436] = true, [184587] = true, [152999] = true, [111850] = true, [173240] = true,
	[145987] = true, [182006] = true, [144330] = true, [142864] = true, [106400] = true,
	[34976] = true, [122752] = true, [99308] = true, [153001] = true, [142865] = true,
	[140092] = true, [144459] = true, [157018] = true, [145065] = true, [186407] = true,
	[144364] = true, [168398] = true, [189627] = true, [164191] = true, [149975] = true,
	[166200] = true, [151697] = true, [156096] = true, [122706] = true, [163364] = true,
	[154981] = true, [186123] = true, [174425] = true, [181597] = true, [120268] = true,
	[108649] = true, [156225] = true, [155225] = true, [139204] = true, [181306] = true,
	[122370] = true, [179864] = true, [117878] = true, [182459] = true, [162346] = true,
	[181753] = true, [180025] = true, [137633] = true, [164004] = true, [105479] = true,
	[162283] = true, [111631] = true, [142863] = true, [187110] = true, [145071] = true,
	[180164] = true, [149980] = true, [115297] = true, [180389] = true, [180166] = true,
	[145263] = true, [123011] = true, [133597] = true, [146124] = true, [164006] = true,
	[143638] = true, [182008] = true, [181275] = true, [188104] = true,
	[112955] = true, [122151] = true, [225080] = true, [147209] = true, [179977] = true,
	[118135] = true, [75056] = true, [155242] = true, [138349] = true, [159558] = true,
	[106794] = true, [189030] = true, [185237] = true, [185014] = true, [155721] = true,
	[82850] = true, [162415] = true, [138732] = true, [182879] = true, [186481] = true,
	[185238] = true, [181508] = true, [118961] = true, [188929] = true, [134366] = true,
	[184360] = true, [185806] = true, [189032] = true, [156934] = true, [135695] = true,
	[157763] = true, [140701] = true, [155277] = true, [144089] = true, [150751] = true,
	[111600] = true, [139202] = true, [181957] = true, [100048] = true, [117436] = true,
	[185241] = true, [116161] = true, [170132] = true, [107268] = true, [145206] = true,
	[143198] = true, [181990] = true, [159947] = true, [157000] = true, [188148] = true,
	[155236] = true, [145175] = true, [160029] = true, [138609] = true, [143445] = true,
	[134912] = true, [117708] = true, [123812] = true, [181099] = true, [144351] = true,
	[142913] = true, [134626] = true, [136857] = true, [107094] = true, [180526] = true,
	[182088] = true, [100024] = true, [139822] = true, [118562] = true, [174716] = true,
	[181515] = true, [182280] = true, [156047] = true, [99126] = true, [176001] = true,
	[156653] = true, [134755] = true, [154932] = true, [143840] = true, [164176] = true,
	[164178] = true, [147665] = true, [106872] = true, [136922] = true, [121949] = true,
	[142948] = true, [164005] = true, [175583] = true, [180079] = true, [155061] = true,
	[136478] = true, [123081] = true, [123705] = true, [147029] = true, [158026] = true,
	[116260] = true, [155030] = true, [187471] = true, [154960] = true, [189551] = true,
	[166579] = true, [118303] = true, [181488] = true, [184324] = true, [155240] = true,
	[134256] = true, [183634] = true, [189031] = true, [145171] = true, [137341] = true,
	[186333] = true, [158315] = true, [184102] = true, [180200] = true, [181841] = true,
	[99256] = true, [155192] = true, [143494] = true, [189434] = true, [159113] = true,
	[185510] = true, [136992] = true, [184964] = true, [158986] = true, [179202] = true,
	[137375] = true, [158010] = true,

	-- 군단 7.0
	[192048] = true, [203774] = true, [222178] = true, [41425] = false, [210863] = true,
	[205201] = true, [210879] = true, [80354] = false, [224188] = true, [204611] = true,
	[217093] = true, [206651] = true, [204895] = true, [208431] = true, [194327] = true,
	[211471] = true, [211802] = true, [196068] = true, [204463] = true, [219024] = true,
	[215449] = true, [197943] = true, [205771] = true, [208929] = true, [219025] = true,
	[221246] = true, [209158] = true, [193783] = true, [210315] = true, [203770] = true,
	[198190] = true, [199063] = true, [204859] = true, [198006] = true, [211939] = true,
	[192706] = true, [204962] = true, [201146] = true, [221028] = true, [203096] = true,
	[218350] = true, [204517] = true, [218368] = true, [193069] = true, [200238] = true,
}

local dispelTypes = { Magic = "Magic", Curse = "Curse", Disease = "Disease", Poison = "Poison" }
local lastTime =  0

local function hideIcon(icon)
	if icon then
		icon:SetSize(0.001, 0.001)
		icon:Hide()
		if GameTooltip:IsOwned(icon) then
			GameTooltip:Hide()
		end
	end
end

local function bossAuraOnUpdate(self, opt)
	if opt == 1 then
		if (self.endTime - GetTime()) > 2.5 then
		self.timerParent.text:SetFormattedText("%d", self.endTime - GetTime() + 0.5)
		else
			self.timerParent.text:SetFormattedText("|cffff0000%.1f|r", self.endTime - GetTime() + 0.5)
		end
	elseif opt == 2 then
		self.timerParent.text:SetFormattedText("%d", GetTime() - self.startTime)
	else
		self.timerParent.text:SetText("")
	end
end

function IRF3:BuildAuraList()
	table.wipe(ignoreAuraId)
	table.wipe(ignoreAuraName)
	table.wipe(bossAuraId)
	table.wipe(bossAuraName)
	for spellid in pairs(IRF3.ignoreAura) do
		if IRF3.db.ignoreAura[spellid] ~= false then
			ignoreAuraId[spellid] = true
		end
	end
	for spell, v in pairs(IRF3.db.ignoreAura) do
		if v == true then
			if type(spell) == "number" then
				ignoreAuraId[spell] = true
			else
				ignoreAuraName[spell] = true
			end
		end
	end
	for spellid2 in pairs(IRF3.bossAura) do
		if (IRF3.db.userAura[spellid2] ~= false) and not ignoreAuraId[spellid2] then
			bossAuraId[spellid2] = true
		end
	end
	for spell2, v in pairs(IRF3.db.userAura) do
		if (v == true) and not ignoreAuraId[spell2] and not ignoreAuraName[spell2] then
			if type(spell2) == "number" then
				bossAuraId[spell2] = true
			else
				bossAuraName[spell2] = true
			end
		end
	end
end

function InvenRaidFrames3Member_SetAuraFont(self)
	self.bossAura.count:SetFont(LibStub("LibSharedMedia-3.0"):Fetch("font", IRF3.db.font.file), IRF3.db.font.size, "THINOUTLINE")
	self.bossAura.count:SetShadowColor(0, 0, 0)
	self.bossAura.count:SetShadowOffset(1, -1)
	self.bossAura.timerParent.text:SetFont(LibStub("LibSharedMedia-3.0"):Fetch("font", IRF3.db.font.file), IRF3.db.font.size, "THINOUTLINE")
	self.bossAura.timerParent.text:SetShadowColor(0, 0, 0)
	self.bossAura.timerParent.text:SetShadowOffset(1, -1)
	for i = 1, 5 do
		local debuffIcon = self["debuffIcon"..i]
		debuffIcon.count:SetFont(LibStub("LibSharedMedia-3.0"):Fetch("font", IRF3.db.font.file), IRF3.db.font.size, "THINOUTLINE")
		debuffIcon.count:SetShadowColor(0, 0, 0)
		debuffIcon.count:SetShadowOffset(1, -1)
	end
end

function InvenRaidFrames3Member_UpdateAura(self)
	self.numDebuffIcons = 0
	local baIndex, baIsBuff, baIcon, baCount, baDuration, baExpirationTime
	local dispelable, dispelType
	for i = 1, 40 do
		local name, _, icon, count, debuffType, duration, expirationTime, _, _, _, spellId, _, isBossAura = UnitDebuff(self.displayedUnit, i)
		-- 디버프 체크
		if name then
			if not ignoreAuraId[spellId] and not ignoreAuraName[name] then
				debuffType = dispelTypes[debuffType] or "none"
				if isBossAura and not bossAuraId[spellId] and not bossAuraName[name] and IRF3.db.userAura[spellId] ~= false and IRF3.db.userAura[name] ~= false then
					IRF3.db.userAura[spellId] = true
					bossAuraId[spellId] = true
					IRF3:Message("새로운 중요 오라(디버프) \""..name.."\"|1을;를; 발견하여 중요 오라 목록에 추가합니다.")
				end
				if self.optionTable.useBossAura and (not baIndex or bsIsBuff) and (bossAuraId[spellId] or bossAuraName[name]) then--디버프는 항상 버프에 우선합니다.
					-- 중요 오라 내용 임시 테이블에 저장
					baIndex = i
					baIsBuff = false
					baIcon = icon
					baCount = count
					baDuration = duration
					baExpirationTime = expirationTime
				elseif self.optionTable.debuffIconFilter[debuffType] and self.optionTable.debuffIcon > self.numDebuffIcons then
					-- 디버프 아이콘
					self.numDebuffIcons = self.numDebuffIcons + 1
					local debuffIcon = self["debuffIcon"..self.numDebuffIcons]
					if debuffIcon then
						debuffIcon:SetSize(self.optionTable.debuffIconSize, self.optionTable.debuffIconSize)
						debuffIcon:SetID(i)
						if IRF3.db.colors[debuffType] then
							debuffIcon.color:SetColorTexture(IRF3.db.colors[debuffType][1], IRF3.db.colors[debuffType][2], IRF3.db.colors[debuffType][3])
						else
							debuffIcon.color:SetColorTexture(0, 0, 0)
						end
						debuffIcon.icon:SetTexture(icon)
						debuffIcon.count:SetText(count and count > 1 and count or nil)
						debuffIcon:Show()
					end
				end
				if not dispelable and LRD:CheckHelpDispel(debuffType) then
					dispelable = true
					dispelType = debuffType
				end
			end
		end
		-- 버프 체크
		local nameB, _, iconB, countB, _, durationB, expirationTimeB, _, _, _, spellIdB, _, isBossAuraB = UnitBuff(self.displayedUnit, i)
		if isBossAuraB and self.optionTable.useBossAura and not ignoreAuraId[spellIdB] and not ignoreAuraName[nameB] and not baIndex then--보스오라로 지정된 경우만 체크합니다. (cpu 사용량 문제)
			if isBossAuraB and not bossAuraId[spellIdB] and not bossAuraName[nameB] and IRF3.db.userAura[spellIdB] ~= false and IRF3.db.userAura[nameB] ~= false then
				IRF3.db.userAura[spellIdB] = true
				bossAuraId[spellIdB] = true
				IRF3:Message("새로운 중요 오라(버프) \""..nameB.."\"|1을;를; 발견하여 중요 오라 목록에 추가합니다.")
			end
			if bossAuraId[spellIdB] or bossAuraName[nameB] then
				-- 중요 오라 내용 임시 테이블에 저장
				baIndex = i
				baIsBuff = true
				baIcon = iconB
				baCount = countB
				baDuration = durationB
				baExpirationTime = expirationTimeB
			end
		end
		if not name and not nameB then
			break
		end
	end
	if baIndex then
		-- 중요 오라 표시
		self.bossAura:SetSize(self.optionTable.bossAuraSize, self.optionTable.bossAuraSize)
		self.bossAura.icon:SetTexture(baIcon)
		self.bossAura.count:SetText(baCount and baCount > 1 and baCount or nil)
		self.bossAura:SetID(baIndex)
		if self.optionTable.bossAuraTimer and baDuration and (baDuration > 0) then
			self.bossAura.cooldown:SetCooldown(baExpirationTime - baDuration, baDuration)
			self.bossAura.cooldown:Show()
		else
			self.bossAura.cooldown:Hide()
		end
		self.bossAura:Show()
		if baDuration and baDuration > 0 and baExpirationTime then
			self.bossAura.endTime = baExpirationTime
			self.bossAura.startTime = baExpirationTime - baDuration
			if not self.bossAura.ticker then
				self.bossAura.ticker = C_Timer.NewTicker(0.1, function() bossAuraOnUpdate(self.bossAura, self.optionTable.bossAuraOpt) end)
			end
			bossAuraOnUpdate(self.bossAura, self.optionTable.bossAuraOpt)
		else
			if self.bossAura.ticker then
				self.bossAura.ticker:Cancel()
				self.bossAura.ticker = nil
			end
			self.bossAura.timerParent.text:SetText(nil)
		end
	else
		hideIcon(self.bossAura)
	end
	for i = self.numDebuffIcons + 1, 5 do
		hideIcon(self["debuffIcon"..i])
	end
	if dispelable then
		self.dispelType = dispelType
		if self.optionTable.dispelSound ~= "None" then
			if GetTime() > lastTime then
				lastTime = GetTime() + self.optionTable.dispelSoundDelay
				PlaySoundFile(SM:Fetch("sound", self.optionTable.dispelSound))
			end
		end
	else
		self.dispelType = nil
	end
end

function InvenRaidFrames3Member_BossAuraOnLoad(self)
	self.cooldown.noOCC = true
	self.cooldown.noCooldownCount = true
	self.cooldown:SetHideCountdownNumbers(true)
end

local tooltipUpdate = 0
function InvenRaidFrames3Member_AuraIconOnUpdate(self, elapsed)
	if not InvenRaidFrames3.tootipState then return end
	tooltipUpdate = tooltipUpdate + elapsed
	if tooltipUpdate > 0.1 then
		tooltipUpdate = 0
		if self:IsMouseOver() then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
			GameTooltip:SetUnitDebuff(self:GetParent().displayedUnit, self:GetID())
		elseif GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end
end
