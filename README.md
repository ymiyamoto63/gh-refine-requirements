# refine-requirements

ビジネスマネージャーが書いた荒い要件メモを、設計フェーズにそのまま渡せる要件定義書に仕上げるスキル。リポジトリ調査 → 選択肢形式のインタビュー（最大30問）→ `docs/requirements/<機能スラッグ>.md` への出力、という流れで動く。

Claude Code と GitHub Copilot の両方で、**同一の SKILL.md** がそのまま動く（Agent Skills 形式）。dev-pipeline のような2形式生成は不要。

リポジトリ名は `gh-refine-requirements`（[GitHub CLI 拡張機能の命名規約](https://docs.github.com/en/github-cli/github-cli/creating-github-cli-extensions)により `gh-` prefix が必須）。スキル自体の名前は `refine-requirements` のまま。

## 特徴

- **質問する前に調べる** — README・`docs/pipeline-config.md`・既存コードを先に調査し、コードを読めば分かることは質問しない
- **選択肢 + 推奨案** — 各質問は2〜4択。推奨案には「（推奨）」と根拠1行が付く。根拠は UI/UX・実装難度・リポジトリの既存設計のいずれかに必ず基づく
- **質問予算 30問** — 影響の大きい質問から消化し、残数を毎回表示。超過分は「未決定事項」として推奨仮置き案・外れた場合の影響とともに記載され、設計フェーズは仮置きで先に進める
- **機能要件が主軸** — 非機能要件は仕様を大きく変えうるもの（認証・権限、個人情報、性能規模、外部連携、法令）のみ確認
- **決定記録・用語集** — 何を聞きどれを選びなぜか、ビジネス用語とシステム概念の対応を文書に残す
- **更新モード** — 出力先に同名ファイルがあれば上書きせず既存文書を更新（FR/AC の ID は振り直さない）
- **dev-pipeline 互換** — AC-ID・検証方法タグ（自動テスト/手動確認）の書式が [dev-pipeline](https://github.com/miyamooo63/dev-pipeline) の requirements-analyst と揃っており、出力をそのまま `/dev-pipeline` に入力できる

## 構成

```
gh-refine-requirements/
├── gh-refine-requirements    … gh CLI 拡張機能のエントリポイント（bash）
├── skills/
│   └── refine-requirements/
│       └── SKILL.md          … スキル本体（Claude Code / Copilot 共通）
└── tools/
    ├── install.ps1           … インストールスクリプト（Windows）
    └── install.sh            … 同上（macOS / Linux / git bash）
```

## インストール

### GitHub Copilot（`gh` コマンド・対象プロジェクト単位・推奨）

[GitHub CLI](https://cli.github.com/) が入っていれば、拡張機能として一度インストールするだけでどのプロジェクトにも使い回せる。

```bash
gh extension install ymiyamoto63/gh-refine-requirements
```

以降、対象プロジェクトのルートで実行するとそのプロジェクトの `.github/skills/refine-requirements/` にインストールされる。

```bash
cd <target-project>
gh refine-requirements
```

カレントディレクトリ以外に入れたい場合は引数でパスを渡す: `gh refine-requirements <target-project>`。

更新時は `gh extension upgrade refine-requirements`。

拡張機能はエントリポイントが bash スクリプトのため、実行には bash が必要（macOS / Linux はそのまま、Windows は Git Bash・WSL 経由）。VS Code / Copilot CLI の Agent Skills サポートが前提。

### GitHub Copilot（`gh` を使わない場合）

```powershell
# Windows (PowerShell) — <target-project> は開発対象リポジトリのルート
.\tools\install.ps1 -CopilotTarget <target-project>
```

```bash
# macOS / Linux
./tools/install.sh --copilot-target <target-project>
```

### Claude Code（ユーザーグローバル）

```powershell
# Windows (PowerShell)
.\tools\install.ps1
```

```bash
# macOS / Linux
./tools/install.sh
```

`~/.claude/skills/refine-requirements/` にコピーされる。配置後、Claude Code の再起動が必要。

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
