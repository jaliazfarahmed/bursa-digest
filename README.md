# Bursa digest

Public JSON feed of recent Bursa Malaysia stock news, compiled by BMB News Bot for the WAZAN mobile app.

WAZAN should `GET` the latest digest each time it opens:

- `https://raw.githubusercontent.com/jaliazfarahmed/bursa-digest/main/digest.json`
- `https://jaliazfarahmed.github.io/bursa-digest/digest.json` (GitHub Pages; may lag slightly after a publish)

Past days are stored under [`archive/`](archive/) as `YYYY-MM-DD.json`.

## File format

Top-level object in `digest.json`:

| Field | Description |
| --- | --- |
| `version` | Schema version (currently `"1.0"`). |
| `digest_date` | Calendar date of the digest (`YYYY-MM-DD`, Asia/Kuala_Lumpur). |
| `updated_at` | When this file was last written (ISO 8601 with `+08:00`). |
| `timezone` | Always `Asia/Kuala_Lumpur`. |
| `source` | Always `BMB News Bot`. |
| `sections` | Three arrays: `contract`, `positive`, `negative`. |

Every item has:

| Field | Description |
| --- | --- |
| `company` | Company name. |
| `stock_code` | Bursa ticker as shown in the source, or `null` if not shown. |
| `category` | `contract`, `positive`, or `negative`. |
| `headline` | One-line headline with the key number. |
| `summary` | Short factual summary from the source. |
| `date` | News date (`YYYY-MM-DD`). |
| `source_name` | Publication name. |
| `source_url` | URL of the fetched article. |
| `caution` | Short caveat, or `null`. |

Contract items also have:

| Field | Description |
| --- | --- |
| `deal_type` | `contract`, `loa`, `jv`, `term_sheet`, `mou`, or `acquisition`. |
| `binding` | `true` for awarded contracts, signed JVs, and binding term sheets; `false` for non-binding MoUs. |
| `value_rm` | Contract or deal value in ringgit, or `null` if not disclosed. |
| `counterparty` | Client, awarder, or partner. |

Negative items also have:

| Field | Description |
| --- | --- |
| `negative_type` | `profit_warning`, `target_missed`, `earnings_decline`, `loss`, `default`, `regulatory`, `legal`, `pn17`, or `going_concern`. |

Classification follows earnings growth, dividends, and contract wins as positive; defaults, losses, profit drops, missed targets, and regulatory or legal action as negative. MoUs are flagged as non-binding. Nothing is invented; every item has a source URL.

## Publishing an update

From the repo directory, replace `digest.json` with the new file, then run:

```bash
./publish.sh
```

The script validates the JSON, copies it to `archive/<digest_date>.json`, commits, and pushes to `main`.
