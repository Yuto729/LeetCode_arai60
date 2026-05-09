6. ZigZag Conversion

The string "PAYPALISHIRING" is written in a zigzag pattern on a given number of rows like this: (you may want to display this pattern in a fixed font for better legibility)

P   A   H   N
A P L S I I G
Y   I   R
And then read line by line: "PAHNAPLSIIGYIR"
Write the code that will take a string and make this conversion given a number of rows:
string convert(string s, int numRows);

Example 1:
Input: s = "PAYPALISHIRING", numRows = 3
Output: "PAHNAPLSIIGYIR"

Example 2:
Input: s = "PAYPALISHIRING", numRows = 4
Output: "PINALSIGYAHRPI"
Explanation:
P     I    N
A   L S  I G
Y A   H R
P     I

Example 3:
Input: s = "A", numRows = 1
Output: "A"

Constraints:
- 1 <= s.length <= 1000
- s consists of English letters (lower-case and upper-case), ',' and '.'.
- 1 <= numRows <= 1000


## Step1
（紆余曲折ありAcceptできたので以下に考え方を整理する）

まずは例1で考える。文字列のそれぞれの文字に番号を振って考える(0-indexedにすればindexと同じ)
sのインデックス0 ~ 13に対して、conversionは以下のように表せる。

0   4   8    12
1 3 5 7 9 11 13
2   6   10

結果を格納する配列を, numRows * 1の空配列として、各行に値を追加していくことでConversionを構築することとする。(この結果配列を`result`とする)
sを一文字ずつ走査してどの行に追加できるか考えてみる。上の図にて、進む方向は "上 -> 下"もしくは"左下 -> 右上"しかない。前者について考えてみると、前者のようなパスで追加される配列のインデックスには法則がある。
つまりkを整数として、`2k * (row - 1) <= i < (2k + 1)(row - 1)`を満たすiは上->下のパスにて走査される要素である。上->下ということは行番号が増加する方向ということ。上記の範囲では行番号を増加させながら`result[r]`に値を追加していく。
上記の範囲が終わったら、`(2k + 1) * (row - 1) <= i < (2k + 2)(row - 1)`の範囲は下->上のパスなので、行番号が減少する方向である。同じように要素を追加する。

言語化があまり上手くない....

45分くらいかかってしまった
- numRows = 1のガードが抜けていた

Time: O(N)
Space: O(N)
```py
class Solution:
    def convert(self, s: str, numRows: int) -> str:
        if numRows == 1:
            return s
            
        rows = [[] for _ in range(numRows)]
        r = 0
        k = 0
        i = 0
        while i < len(s):
            while 2 * k * (numRows - 1) <= i < min((2 * k + 1) * (numRows - 1), len(s)):
                rows[r].append(s[i])
                i += 1
                r += 1
            while (2 * k + 1) * (numRows - 1) <= i < min(2 * (k + 1) * (numRows - 1), len(s)):
                rows[r].append(s[i])
                i += 1
                r -= 1
            k += 1
        
        result = ""
        for r in rows:
            result += "".join(r)
        
        return result
```

AIに聞いて簡略化のヒントを得る。
> 行番号 r を +1/-1で振動させる発想（端で反転）にすれば、kや範囲計算なしで一重ループで書けます

```py
class Solution:
    def convert(self, s: str, numRows: int) -> str:
        if numRows == 1:
            return s
            
        rows = [[] for _ in range(numRows)]
        r = 0
        is_r_increasing = True
        for ch in s:
            rows[r].append(ch)
            if r == numRows - 1:
                is_r_increasing = False
            if r == 0:
                is_r_increasing = True

            if is_r_increasing:
                r += 1
            else:
                r -= 1

        result = ""
        for r in rows:
            result += "".join(r)
        
        return result
```
- ひとまずフラグを使って書いてみたが、もう少し簡単にならないか
    - 単に方向を変数として持っておけば良さそう

- 冒頭の `if numRows == 1`はforループ内での冗長な条件分岐をあらかじめ回避するための特殊ケース
```py
class Solution:
    def convert(self, s: str, numRows: int) -> str:
        if numRows == 1:
            return s
            
        rows = [[] for _ in range(numRows)]
        r = 0
        # rを進める方向
        direction = 1
        for ch in s:
            rows[r].append(ch)
            if r == numRows - 1:
                direction = -1
            if r == 0:
                direction = 1
            
            r += direction

        result = ""
        for r in rows:
            result += "".join(r)
        
        return result
```