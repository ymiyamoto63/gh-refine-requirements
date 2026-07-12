# refine-requirements

ビジネスマネージャーが書いた荒い要件メモを、設計フェーズにそのまま渡せる要件定義書に仕上げるスキル。リポジトリ調査 → 選択肢形式のインタビュー（最大30問）→ `docs/requirements/<機能スラッグ>.md` への出力、という流れで動く。

Claude Code と GitHub Copilot の両方で、**同一の SKILL.md** がそのまま動く（Agent Skills 形式）。dev-pipeline のような2形式生成は不要。

スキルは `skills/refine-requirements/SKILL.md` に置かれており、[Agent Skills 仕様](https://agentskills.io/specification)の `skills/*/SKILL.md` 規約に従っているため、`gh skill install` でそのままインストールできる。リポジトリ名の `gh-` prefix は旧 gh CLI 拡張機能時代の名残（拡張機能は非推奨、後述）。スキル自体の名前は `refine-requirements`。

## 特徴

- **質問する前に調べる** — README・`docs/pipeline-config.md`・既存コードを先に調査し、コードを読めば分かることは質問しない。調査で仮確定した判断は「制約 > 前提」に明示され、レビュー時に否認できる
- **選択肢 + 推奨案** — 各質問は2〜4択。推奨案には「（推奨）」と根拠1行が付く。根拠はビジネス目的・UI/UX・実装難度・リポジトリの既存設計のいずれかに必ず基づく
- **抜け漏れチェックリスト** — アクターと権限 / 異常系・エッジケース / データ（形式・保持・移行）/ スコープ境界 / 同時実行・通知・監査ログ、という定番の落とし穴を列挙時に必ず確認
- **質問予算 30問（上限であって目標ではない）** — 典型的なメモは8〜15問で収束。影響の大きい質問から消化し、残数を毎回表示。超過分は「未決定事項」として推奨仮置き案・外れた場合の影響・確認先とともに記載され、設計フェーズは仮置きで先に進める
- **決定の逐次記録** — 各ラウンドの回答はその場で出力ファイルの決定記録に追記されるため、長い対話でも序盤の決定が失われない
- **機能要件が主軸** — 非機能要件は仕様を大きく変えうるもの（認証・権限、個人情報、性能規模、外部連携、法令）のみ確認
- **決定記録・用語集** — 何を聞きどれを選びなぜか、ビジネス用語とシステム概念の対応を文書に残す
- **更新モード** — 出力先に同名ファイルがあれば上書きせず既存文書を更新（FR/AC の ID は振り直さない）
- **dev-pipeline 互換** — AC-ID・検証方法タグ（自動テスト/手動確認）の書式が [dev-pipeline](https://github.com/miyamooo63/dev-pipeline) の requirements-analyst と揃っており、出力をそのまま `/dev-pipeline docs/requirements/<feature-slug>.md` として入力できる（dev-pipeline 側が既存要件書入力モードとして認識し、未決定事項の解消 → 承認 → Issue・ブランチ作成へ進む）。全 FR は少なくとも1つの AC でカバーされる

## 構成

```
gh-refine-requirements/
├── gh-refine-requirements    … 旧 gh CLI 拡張機能のエントリポイント（非推奨）
├── docs/
│   └── SKILL_jp.md           … SKILL.md の日本語参考訳（閲覧用。エージェントには読み込まれない）
├── skills/
│   └── refine-requirements/
│       └── SKILL.md          … スキル本体（Claude Code / Copilot 共通）
└── tools/
    ├── install.ps1           … インストールスクリプト（gh が使えない場合の代替・Windows）
    └── install.sh            … 同上（macOS / Linux / git bash）
```

## インストール

[GitHub CLI](https://cli.github.com/) **v2.90.0 以降**の `gh skill install` を使う（推奨）。

### GitHub Copilot（対象プロジェクト単位）

対象プロジェクトのルートで:

```bash
gh skill install ymiyamoto63/gh-refine-requirements refine-requirements
```

プロジェクトの `.agents/skills/refine-requirements/` にインストールされる（Copilot / Cursor / Codex / Gemini CLI などが共有で読むディレクトリ）。

### Claude Code（ユーザーグローバル）

```bash
gh skill install ymiyamoto63/gh-refine-requirements refine-requirements --agent claude-code --scope user
```

`~/.claude/skills/refine-requirements/` にインストールされる。配置後、Claude Code の再起動が必要。プロジェクト単位で入れたい場合は `--scope user` を外す（`.claude/skills/` に入る）。

### 更新

```bash
gh skill update
```

インストール済みスキルの frontmatter に出所（リポジトリ・ref・SHA）が記録されており、これを元に更新される。

### `gh skill` が使えない場合の代替

gh CLI が v2.90.0 未満、または使えない環境では、同梱スクリプトでコピーできる。

```powershell
# Windows (PowerShell)
.\tools\install.ps1                                  # Claude Code（~/.claude/skills/）
.\tools\install.ps1 -CopilotTarget <target-project>  # Copilot（<target-project>/.github/skills/）
```

```bash
# macOS / Linux
./tools/install.sh                                   # Claude Code
./tools/install.sh --copilot-target <target-project> # Copilot
```

旧方式の gh CLI 拡張機能（`gh extension install ymiyamoto63/gh-refine-requirements` → `gh refine-requirements`）は非推奨。動作はするが、今後は `gh skill install` を使うこと。

## 使い方

Claude Code:

```
/refine-requirements <荒い要件のテキスト、またはメモファイルのパス>
```

Copilot Chat / Copilot CLI では、荒い要件を渡して要件定義を依頼すればスキルが起動する（「この要件メモを要件定義書にして: docs/memo.md」など）。

例:

```
/refine-requirements 営業チームが顧客一覧をCSVでダウンロードできるようにしたい。管理者だけ全件、それ以外は自分の担当分だけ。
```

対話が終わると、対象プロジェクトの `docs/requirements/customer-csv-export.md` のような形で要件定義書が出力される。

## 出力される要件定義書の構成

概要 / 背景・目的 / スコープ / 対象外 / 影響範囲 / 機能要件（FR-1…）/ 画面・UIフロー / 受け入れ基準（AC-1… + 検証方法タグ）/ 制約 / 重大な非機能要件 / 未決定事項 / 決定記録 / 用語集

## 前提・制約

- 設計・実装はしない。成果物は要件定義書のみ
- 1機能 = 1ファイル。荒い要件に複数機能が混在している場合は分割を提案する
- 文書は日本語で出力（指示があれば変更可）
