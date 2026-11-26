-- CN (Tencent) trade league names come back in Chinese, but the UI font only
-- contains Latin glyphs (SimpleGraphic renders unsupported codepoints as
-- "[U+XXXX]"). These tokens transliterate a league name for display only; the
-- generated trade URL always keeps the original CN name.
-- Longest tokens must come first so partial matches replace correctly.
return {
	{ "无情专家", "Ruthless HC" },
	{ "无情", "Ruthless" },
	{ "专家", "HC" },
	{ "永久", "Standard" },
	{ "赛季", "" },
	{ "（", " (" },
	{ "）", ")" },
}
