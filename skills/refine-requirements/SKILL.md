---
name: refine-requirements
description: Turn a rough, business-level requirements memo into a design-ready requirements document through a structured multiple-choice interview (max 30 questions), saved to docs/requirements/<feature-slug>.md. Use this skill whenever the user provides draft or rough requirements, a feature memo from a business manager or stakeholder, or asks to 要件定義 / 要件を詰める / refine requirements / create a requirements document — even if they don't name this skill explicitly. Do not use it for tasks that are already fully specified or for pure research questions.
---

# refine-requirements

You receive rough requirements written by a business manager — typically incomplete, ambiguous, and written in business language — and turn them into a requirements document precise enough to hand to a design phase without the designer having to guess. You do this by investigating the repository first, then interviewing the user with multiple-choice questions, then writing the document.

Do not design the solution and do not write code. Your deliverable is the requirements document.

## Input

The rough requirements arrive as chat text or as a path to a file (.md / .txt — read it). If neither is given, ask for them before doing anything else. If the input mixes several independent features, point that out and propose splitting into one document per feature (the output convention is one file per feature); let the user choose before interviewing.

## Step 1 — Investigate before asking

Never ask a question you could answer yourself. Before the interview, survey the target project (the current working directory unless told otherwise):

- `README`, `docs/` (especially `docs/pipeline-config.md` and existing `docs/requirements/*.md` if present) for conventions and prior decisions.
- The code areas the feature touches: existing similar features, screen/routing structure, API patterns, data model. This is what grounds your recommendations later.

Resolve everything you can from this survey. What remains is the interview material. Keep track of ambiguities you resolve from the survey *instead of* asking — they are inferences, not user decisions, and go into the 前提 list of the 制約 section so the user can veto a wrong inference when reviewing the document.

## Step 2 — Interview loop

In one single pass, enumerate every ambiguity that materially changes what gets built — do not split this into a functional pass followed by a separate non-functional check, since a non-functional finding (e.g. a compliance or data-sensitivity concern) discovered late can reshape functional decisions you already batched and asked about. The list mixes two kinds of item:

- **Functional ambiguities** (the main subject): behavior, screens, data, edge cases, permissions-as-behavior.
- **Non-functional ambiguities, but only ones that can materially reshape the spec**: authentication/authorization model, handling of personal or sensitive data, data volume / performance at a scale that changes the design, availability of external integrations, legal/compliance constraints. Routine NFRs (general performance wishes, logging conventions) don't belong on the list at all.

When enumerating, sweep this coverage checklist — these are the classic omissions in requirements work:

- アクターと権限: 誰が使うか、ロールによって挙動が変わるか
- 異常系・エッジケース: 入力不正 / 0件 / 上限超過 / 外部サービス障害時の挙動
- データ: 入出力の形式、保持期間、**既存データの移行の要否**
- スコープ境界: メモに書かれていないが隣接する機能を、やるのか・やらないのか
- 同時実行・競合、通知・監査ログの要否

The checklist governs *enumeration only* — whether an item becomes a question still follows the impact ordering and the budget below. An item that is obviously irrelevant to this feature is simply skipped.

Order the combined list by impact — questions whose answer forks the spec widely come first — so the budget is spent where it matters most.

**Budget: 30 questions total, hard cap.** State the running count *before* presenting each round's questions (e.g. `質問 5–8 / 30`), not only in the final wrap-up. Stop early the moment no material ambiguity remains — never pad toward 30. Anything still open when the budget runs out becomes a 未決定事項 (see Step 3).

Present questions in batches of up to 4 related questions per round to reduce round-trips. Each question:

- 2–4 concrete options, mutually exclusive where possible.
- Mark the recommended option with 「（推奨）」 and a one-line rationale. Ground every recommendation in at least one of: **the stated business goal** (what best serves the memo's 背景・目的), **UI/UX** (what is least surprising for the end user), **implementation difficulty** (what is cheapest/safest to build), or **the repository's current design** (what matches existing patterns you found in Step 1). Say which. A recommendation you cannot ground, don't mark — an ungrounded 推奨 is worse than none.
- If the environment provides an `AskUserQuestion` tool, use it (recommended option first, labeled 「（推奨）」). Otherwise — e.g. GitHub Copilot — present the options as a numbered list in chat and wait for the answer before continuing. Free-text answers outside the options are always valid; fold them in as given.

Budget accounting: every option-question actually presented to the user counts, including follow-ups that an answer opens up. Asking for the input memo, proposing a feature split, and confirming a filename do not count. If an answer contradicts the rough memo or an earlier answer, point out the contradiction and confirm which wins before folding it in (this confirmation counts as a question) — a silently absorbed contradiction poisons the whole document.

## Step 3 — Undecided items

Every question that remains open when the budget is exhausted (or that the user explicitly defers) goes into the 未決定事項 section. Each entry carries: the question, the options considered, **a recommended provisional answer with rationale**, and the impact/risk if the recommendation turns out wrong — so the design phase can proceed on the stated assumption instead of stalling. When the answer belongs to someone other than the interviewee (法務、営業部長、外部ベンダーなど — typically because the user answered 「わからない」「要確認」), also record 確認先: who should resolve it. Never silently fold a provisional answer into the body of the document as if it were decided.

## Step 4 — Write the document

Output path: `<project_root>/docs/requirements/<feature-slug>.md`, where `<feature-slug>` is a short kebab-case English slug that captures the feature (e.g. `avatar-upload.md`, `csv-export.md`). Create parent directories if needed. State the filename when you write it; only ask about it if genuinely ambiguous.

**Update mode:** if the file already exists, do not overwrite blindly. Read it first: if it describes a *different* feature that happens to share the slug, pick a different slug instead of merging. If it is an earlier version of this feature, tell the user and fold the new information into the existing document — resolve its 未決定事項 where the new answers apply, update affected sections, and append to 決定記録. Requirements documents get revised, not rewritten.

Write the document content in Japanese unless told otherwise. Use exactly this structure — a section with nothing to say gets 「なし」 rather than being removed, so downstream phases can rely on the shape:

```markdown
# <機能名>

## 概要
<何を作るか、1段落>

## 背景・目的
<なぜ作るか。ビジネス上の狙い>

## スコープ
<作る/直すものの具体的な箇条書き>

## 対象外（Non-goals）
<今回は明示的にやらないこと>

## 影響範囲
<この機能が触れるレイヤーを対象プロジェクトの構成に即して具体的に（例: 画面コンポーネント / フロント状態管理 / APIクライアント / バックエンドAPI / サービスロジック / DBスキーマ）。設計・テストフェーズが何に手を入れるかの判断に使う>

## 機能要件
- FR-1: <検証可能な粒度の要件>
- FR-2: …

## 画面・UIフロー
<関係する画面と遷移。既存画面への追加なら既存構造に言及>

## 受け入れ基準
- AC-1: <条件>（検証方法: 自動テスト / 手動確認）
- AC-2: …

## 制約
<既存アーキテクチャ・ライブラリ・規約のうち設計が従うべきもの（Step 1 の調査結果）>

### 前提（調査により確認）
<質問の代わりに Step 1 の調査で仮確定した判断の一覧。誤った推測をユーザーがレビュー時に否認できるよう明示する。なければ「なし」>

## 重大な非機能要件
<仕様に影響する項目のみ。なければ「なし」>

## 未決定事項
- <質問> — 選択肢: <A / B> / 推奨仮置き: <A>（<根拠>）/ 外れた場合の影響: <…> / 確認先: <誰・どの部署>（決定権が回答者以外にある場合のみ）

## 決定記録
- Q1: <質問> → <選ばれた選択肢>（理由: <…>）

## 用語集
<ビジネス用語 ↔ システム上の概念の対応。齟齬が出やすい語のみ>
```

Section-specific notes:

- **FR / AC の ID は安定参照** — downstream phases (design, tests, review) cite them, so never renumber existing IDs when updating.
- **受け入れ基準** — every FR must be covered by at least one AC; an FR with no AC is a requirement nobody will verify. Cover the main 異常系 paths, not just the happy path. Prefer mechanically checkable conditions; tag each with 自動テスト or 手動確認 so the testing effort is visible up front. This format is compatible with dev-pipeline's requirements-analyst output, so the document can feed straight into a `/dev-pipeline` run.
- **決定記録** — one line per answered interview question: what was asked, what was chosen, why. This is what lets a designer six months later understand why the spec says what it says. Answers accepted as the recommended default still get a line.
- **用語集** — business-manager vocabulary is where misunderstandings breed; map each ambiguous business term to the concrete system concept it means here. Skip terms that are unambiguous.

## Wrap-up

Your final message: the file path written, the number of questions used out of 30, and the list of 未決定事項 with their recommended provisional answers (if any) so the user can act without opening the file. If the user replies with corrections or disagreements, fold them in via update mode — don't restart the interview.

Be concise throughout. A requirements document that takes ten minutes to read is worse than one that takes two.
