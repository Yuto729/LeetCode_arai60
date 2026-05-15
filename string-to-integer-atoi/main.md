8. String to Integer (atoi)
Implement the myAtoi(string s) function, which converts a string to a 32-bit signed integer.

The algorithm for myAtoi(string s) is as follows:

Whitespace: Ignore any leading whitespace (" ").
Signedness: Determine the sign by checking if the next character is '-' or '+', assuming positivity if neither present.
Conversion: Read the integer by skipping leading zeros until a non-digit character is encountered or the end of the string is reached. If no digits were read, then the result is 0.
Rounding: If the integer is out of the 32-bit signed integer range [-2^31, 2^31 - 1], then round the integer to remain in the range. Specifically, integers less than -2^31 should be rounded to -2^31, and integers greater than 2^31 - 1 should be rounded to 2^31 - 1.
Return the integer as the final result.

Example 1:
Input: s = "42"
Output: 42

Explanation:
The underlined characters are what is read in and the caret is the current reader position.
Step 1: "42" (no characters read because there is no leading whitespace)
         ^
Step 2: "42" (no characters read because there is neither a '-' nor '+')
         ^
Step 3: "42" ("42" is read in)
           ^
Example 2:
Input: s = " -042"
Output: -42

Explanation:
Step 1: "   -042" (leading whitespace is read and ignored)
            ^
Step 2: "   -042" ('-' is read, so the result should be negative)
             ^
Step 3: "   -042" ("042" is read in, leading zeros ignored in the result)
               ^
Example 3:
Input: s = "1337c0d3"
Output: 1337

Explanation:
Step 1: "1337c0d3" (no characters read because there is no leading whitespace)
         ^
Step 2: "1337c0d3" (no characters read because there is neither a '-' nor '+')
         ^
Step 3: "1337c0d3" ("1337" is read in; reading stops because the next character is a non-digit)
             ^
Example 4:
Input: s = "0-1"
Output: 0

Explanation:
Step 1: "0-1" (no characters read because there is no leading whitespace)
         ^
Step 2: "0-1" (no characters read because there is neither a '-' nor '+')
         ^
Step 3: "0-1" ("0" is read in; reading stops because the next character is a non-digit)
          ^
Example 5:
Input: s = "words and 987"
Output: 0

Explanation:
Reading stops at the first non-digit character 'w'.

Constraints:
- 0 <= s.length <= 200
- s consists of English letters (lower-case and upper-case), digits (0-9), ' ', '+', '-', and '.'.

## Step1
問題文に従って愚直に処理をする。数々のコーナーケースに引っ掛かり30分くらいかかった
```py
class Solution:
    def myAtoi(self, s: str) -> int:
        digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        INT_MAX = 2 ** 31 - 1
        INT_MIN = -2 ** 31

        # eliminate left whitespace
        s = s.lstrip()
        
        if not s:
            # corner case
            return 0

        # detect sign
        sign = 1
        if s[0] == "-":
            sign = -1

        # read until non-digit skipping leading zeros
        i = 0
        if sign == -1 or s[0] == "+":
            # 後半もcorner case
            i = 1

        abs_num = 0
        while i < len(s):
            if s[i] not in digits:
                break
            
            abs_num = abs_num * 10 + int(s[i])
            i += 1

        # rounding
        if sign == -1 and abs_num > abs(INT_MIN):
            return INT_MIN
        
        if sign == 1 and abs_num > INT_MAX:
            return INT_MAX

        return sign * abs_num
```

## 引っかかったコーナーケース・構文の振り返り

### コーナーケース

- 空文字列 / 全部whitespace (`""`, `"   "`)
  - whitespace除去後にそのまま `s[0]` を見ると IndexError
  - → `if not s: return 0` を追加
- 明示的な `+` 符号 (`"+1"`)
  - `+` を非数字扱いで break してしまい 0 を返した
  - → `s[0] == "+"` のときも `i = 1` でスキップ
- 文字間のスペース (`"words and 987"`, `"  - 42"`)
  - 自前ループで全スペースを消すと `"wordsand987"` になり誤動作
  - → 「leading whitespace のみ」除去すべき。`s.lstrip()` に変更
- 32bit範囲外 (`"91283472332"`, `"-91283472332"`)
  - そのまま巨大数を返してしまう
  - → `INT_MAX` / `INT_MIN` でクランプ
- 負側の境界 (`-2^31`)
  - `abs_num > INT_MAX` で判定すると `2^31` が INT_MAX 扱いになる
  - → 符号別に `abs(INT_MIN)` (= `2^31`) と比較
- 非数字で打ち切り (`"1337c0d3"`, `"0-1"`)
  - `s[i] not in digits: break` でOK

### 構文・実装ミス

- `s.lstrip()` の戻り値を捨てた
  - Pythonの文字列は immutable。`lstrip()` は新しい文字列を返すだけ
  - → `s = s.lstrip()` と再代入する
- 空白除去を自前ループで実装した
  - `for ch in s: if ch == " ": continue` だと中間スペースも消える
  - → `lstrip()` で左端のみ除去
- 符号スキップ条件が `+` を漏らした
  - `if sign == -1: i = 1` だけだと `+` の場合 `i=0` のまま
  - → `if sign == -1 or s[0] == "+": i = 1`


綺麗にする
```py
class Solution:
    def myAtoi(self, s: str) -> int:
        INT_MAX = 2 ** 31 - 1
        INT_MIN = -2 ** 31
        s = s.lstrip()
        if not s:
            return 0

        sign = 1
        start = 0
        if s[0] in ("+", "-"):
            if s[0] == "-":
                sign = -1
            start = 1

        abs_num = 0
        # s[start:]は新しい文字列を作るが、200文字制約なので問題はない
        for ch in s[start:]:
            if not ch.isdigit():
                break
            
            abs_num = abs_num * 10 + int(ch)
            
        if sign * abs_num < INT_MIN:
            return INT_MIN
        
        if sign * abs_num > INT_MAX:
            return INT_MAX

        return sign * abs_num
```
- Pythonは任意精度整数なので最後にクランプですむが、固定幅整数の言語ではループ内で検知が必要
以下のようにガードを書けばC++などでも使えるはず
```py
INT_MAX = 2 ** 31 - 1

# 正であれば絶対値は2**31 - 1, 負であれば絶対値は2**31になるため
limit = INT_MAX if sign == 1 else INT_MAX + 1
for ch in s[start:]: 
    if not ch.isdigit():
        break
    
    digit = int(ch)
    if abs_num > (limit - digit) // 10:
        return INT_MAX if sign == 1 else INT_MIN

    abs_num = abs_num * 10 + digit
```
↑これだとまだ不十分

他の解法
- 正規表現
- DFA（決定性有限オートマトン）正規表現も同じ

Follow up
- 小数点 / 指数表記に対応する
- isdigitの挙動 -> 全角数字もTrueになる. ASCII限定にするなら '0' <= ch <= '9'とかにする

## Step2

### INT_MIN ちょうどの扱いでオーバーフローしやすい
[shining-ai#59](https://github.com/shining-ai/leetcode/pull/59) 
- https://discord.com/channels/1084280443945353267/1201211204547383386/1232407641284935770
> level 2 は、入力が INT_MIN ちょうどのときに、-(INT_MAX+1) と計算しているのでオーバーフローしているのでは。

`sign * abs_num` や `limit = INT_MAX + 1` のように`2^31` を一瞬でも作る書き方は、C++/Java の `int` ではオーバーフローする（自分の解も同じ）。

回避するためには 閾値を `INT_MAX` のみに統一 する。負側の `-2147483648` は `INT_MAX` 基準でオーバーフロー判定されるが、それによって返る値 `INT_MIN` が真の値と一致するためバグらない:
```py
result = 0
for ch in s[start:]:
    if not ch.isdigit(): break
    digit = int(ch)
    if result > INT_MAX // 10 or (result == INT_MAX // 10 and digit > INT_MAX % 10):
        return INT_MAX if sign == 1 else INT_MIN
    result = result * 10 + digit
return sign * result
```
`result` は `2^31` に到達しないので C++ の `int` のまま安全。

### オーバーフロー判定はマジックナンバーを避ける
[shining-ai#59](https://github.com/shining-ai/leetcode/pull/59/files#r1577944706)
> せっかくINT_MAXを定義しているので1の位の値でオーバーフローするかどうか判定する部分もINT_MAXを使って書きたい気持ちがあります。

`if next_digit >= 7:` ではなく `if next_digit >= INT_MAX % 10:` と書く。

### `%` 演算子の符号は言語で異なる
[shining-ai#59](https://github.com/shining-ai/leetcode/pull/59)
> The modulo operator always yields a result with the same sign as its second operand.
> `%`のマイナスで割る際の結果は言語ごとに違います。`/`で切り捨てる際に0方向か負の無限大方向に切り捨てるかの話も同様ですね。

- Python: 結果の符号は 第2オペランドと同じ（`-7 % 10 == 3`）
- C/C++/Java: 結果の符号は 第1オペランドと同じ（`-7 % 10 == -7`）
- Haskell: `mod`（Python型）と `rem`（C型）を明確に区別。

### `long` は環境依存（LLP64 では 32bit）
[Ryotaro25#64](https://github.com/Ryotaro25/leetcode_first60/pull/64)
> long は 64ビットデータモデルによっては 32-bit となる点に注意しましょう。

Windows (LLP64) では `long` は 32bit。Linux/macOS (LP64) では 64bit。移植性のあるコードは `int64_t` / `long long` を使う。

### `int()` も実装する
[mamo3gr#54](https://github.com/mamo3gr/arai60/pull/54)
> 仮に自分がこの問題を面接で出題するとしたら、 int() の実装をするようお願いすると思います。おそらくここがこの問題のポイントの一つなのではないかと思います。

まさにその通り. `int(ch)` も結局この問題と同じ処理を内部でやっているので、int()を実装したい。
Unicodeポイントが連続しているという性質を用いて、"0"を基準として以下のように整数に変換できる
`ord(ch) - ord("0")`

補足: 16進数などへの拡張
'A' - 'A' + 10という発想で、16進数にも拡張できる
```py
def hex_digit(ch):                                                       
    if '0' <= ch <= '9':
        return ord(ch) - ord('0')
    if 'a' <= ch <= 'f':
        return ord(ch) - ord('a') + 10
    if 'A' <= ch <= 'F':
        return ord(ch) - ord('A') + 10
    raise ValueError
```
### `isdigit()` はロケール / Unicode 依存
[Ryotaro25#64](https://github.com/Ryotaro25/leetcode_first60/pull/64)
- Python の `str.isdigit()` は 全角数字 `"１"` も True、漢数字の一部（`"²"`）も True。
    - https://docs.python.org/3/library/stdtypes.html#str.isdigit
- C++ の `std::isdigit` も `<cctype>` だとロケール依存（[cpprefjp](https://cpprefjp.github.io/reference/cctype/isdigit.html)）。
- ASCII 限定にするなら `'0' <= ch <= '9'` か `ch in "0123456789"` で書く方が安全。

### 切り捨て方向に注意した overflow 判定
[naoto-iwase#60](https://github.com/naoto-iwase/leetcode/pull/60)
> 負の数の割り算における切り捨ての影響で正しく動かないと思います。digit にオーバーフローすべき大きい値が来た時、`self.INT_MIN + digit` の十の位は 1 小さくなりますが、`//10` によりその影響が消されてしまいます。

前提
```py
a = -95
math.ceil(a / 10) # -9
a // 10 # -10
```
上記のような違いがある違いがある。
負の数を `//10`（床関数）で切ると `math.ceil` と1ずれる。`math.ceil`は商を浮動点小数に一時的にするので、回避策として被除数に `+9` してから `//10`で天井関数を表現できる:
```py
# value < math.ceil((INT_MIN + digit_abs) / 10) と等価
if value < (INT_MIN + digit_abs + 9) // 10:
    return INT_MIN
```

### 関数分割の温度感
[philip82148#6](https://github.com/philip82148/leetcode-swejp/pull/6)
> この関数、テストしたい部分が、`if (ret < kMin / 10 || (ret == kMin / 10 && digit <= kMin % 10)) {` この行くらいで、バグがないと一目では言えないでしょう。そうするとテストするために分けるのは一つですね。

「処理の関心ごとに分ける」が常に正解ではなく、テストしたい単位かどうかで判断するのが実用的。粒度が揃わないなら分けるのも一案。

### Step3
```py
class Solution:
    INT_MAX = 2 ** 31 - 1
    INT_MIN = -2 ** 31

    def would_overflow(self, num: int, digit: int) -> bool:
        return num > self.INT_MAX // 10 or (num == self.INT_MAX // 10 and digit > self.INT_MAX % 10)

    def myAtoi(self, s: str) -> int:
        s = s.lstrip()
        if not s:
            return 0

        sign = 1
        start = 0
        if s[0] in ("+", "-"):
            if s[0] == "-":
                sign = -1
            start = 1

        abs_num = 0
        for ch in s[start:]: 
            if not ("0" <= ch <= "9"):
                break
            
            digit = ord(ch) - ord("0")
            if self.would_overflow(abs_num, digit):
                return self.INT_MAX if sign == 1 else self.INT_MIN

            abs_num = abs_num * 10 + digit

        return sign * abs_num
```

## 類題

- [LeetCode 7. Reverse Integer](https://leetcode.com/problems/reverse-integer/) — 同じ32bitオーバーフロー判定の練習
- [LeetCode 65. Valid Number](https://leetcode.com/problems/valid-number/) — 小数点・指数表記対応で DFA がほぼ必須
- [LeetCode 415. Add Strings](https://leetcode.com/problems/add-strings/) — `int()` 禁止で文字列の数字を1桁ずつ処理
- [LeetCode 43. Multiply Strings](https://leetcode.com/problems/multiply-strings/) — 同上で乗算
- [LeetCode 12. Integer to Roman](https://leetcode.com/problems/integer-to-roman/) — 逆方向の変換
