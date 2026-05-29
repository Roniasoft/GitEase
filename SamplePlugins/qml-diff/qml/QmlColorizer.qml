import QtQuick

QtObject {
    readonly property var keywords: [
        "import","property","signal","function","var","let","const",
        "if","else","for","while","do","break","continue","return",
        "switch","case","default","try","catch","finally","throw",
        "new","delete","typeof","instanceof","in","of",
        "true","false","null","undefined","this",
        "readonly","required","pragma","as","alias"
    ]
    readonly property var builtins: [
        "console","Math","JSON","Date","Qt","Object","Array",
        "parseInt","parseFloat","isNaN"
    ]

    function colorize(raw) {
        if (!raw || raw.length === 0) return ""

        // Find single-line comment start (outside strings)
        var commentIdx = -1
        var inStr = false, strChar = ""
        for (var ci = 0; ci < raw.length; ci++) {
            var ch = raw[ci]
            if (inStr) {
                if (ch === "\\") { ci++; continue }
                if (ch === strChar) inStr = false
            } else {
                if (ch === '"' || ch === "'" || ch === "`") { inStr = true; strChar = ch }
                else if (ch === "/" && raw[ci+1] === "/") { commentIdx = ci; break }
            }
        }

        var code    = commentIdx >= 0 ? raw.substring(0, commentIdx) : raw
        var comment = commentIdx >= 0 ? raw.substring(commentIdx)    : ""

        var out = ""
        var i = 0
        while (i < code.length) {
            var c = code[i]

            // String literal
            if (c === '"' || c === "'" || c === "`") {
                var q = c, s = c, j = i + 1
                while (j < code.length) {
                    var sc = code[j]; s += sc
                    if (sc === "\\") { j++; if (j < code.length) { s += code[j]; j++ }; continue }
                    if (sc === q) { j++; break }
                    j++
                }
                out += '<font color="#CE9178">' + _esc(s) + '</font>'
                i = j; continue
            }

            // Identifier / keyword
            if (/[a-zA-Z_$]/.test(c)) {
                var word = "", k = i
                while (k < code.length && /[a-zA-Z0-9_$.]/.test(code[k]))
                    word += code[k++]
                var base = word.split(".")[0]

                if (keywords.indexOf(base) >= 0)
                    out += '<b><font color="#569CD6">' + _esc(word) + '</font></b>'
                else if (builtins.indexOf(base) >= 0)
                    out += '<font color="#DCDCAA">' + _esc(word) + '</font>'
                else if (/^on[A-Z]/.test(word))
                    out += '<font color="#C586C0">' + _esc(word) + '</font>'
                else if (/^[A-Z]/.test(word))
                    out += '<font color="#4EC9B0">' + _esc(word) + '</font>'
                else if (k < code.length && /\s*:/.test(code.substring(k, k+3)))
                    out += '<font color="#9CDCFE">' + _esc(word) + '</font>'
                else
                    out += _esc(word)
                i = k; continue
            }

            // Number
            if (/[0-9]/.test(c) || (c === "." && /[0-9]/.test(code[i+1] || ""))) {
                var num = "", n = i
                while (n < code.length && /[0-9a-fA-FxX.]/.test(code[n]))
                    num += code[n++]
                out += '<font color="#B5CEA8">' + _esc(num) + '</font>'
                i = n; continue
            }

            out += _esc(c)
            i++
        }

        if (comment)
            out += '<i><font color="#6A9955">' + _esc(comment) + '</font></i>'

        return out
    }

    function _esc(t) {
        return t.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;")
                .replace(/\t/g,"&nbsp;&nbsp;&nbsp;&nbsp;").replace(/ /g,"&nbsp;")
    }
}
