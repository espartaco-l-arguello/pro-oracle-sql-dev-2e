# Apress Source Code (Fixed & Automated)

This repository accompanies [*Pro Oracle SQL Development, 2nd Edition*](https://link.springer.com/book/10.1007/978-1-4842-8867-2) by Jon Heller (Apress, 2023).

[comment]: #cover
![Cover image](978-1-4842-8866-5.jpg)

## 🛠️ Docker & Container Fixes included in this fork

If you are following the book and trying to load the `SPACE_EXPORTER` data inside a modern Docker container (e.g., `oracle/database:23ai-free`), you will likely encounter several severe errors when executing the original code:

*   **`ORA-29283: invalid file operation`** or `KUP-04040: file all in SDB not found`: This happens because the original setup assumes specific host paths exist, and the raw `.tar.gz` and `.zip` files aren't extracted automatically.
*   **Package Compilation Errors:** The original `space_exporter.pck` is missing `data_dump.sql` and suffers from `INHERIT PRIVILEGES` and `AUTHID CURRENT_USER` issues.

**We have provided an automated setup script to fix all of this.**

### How to use the automated setup

If you are running Oracle in a Docker container named `oracledb`, simply run:

```bash
./scripts/install_space_exporter.sh
```

This script will automatically:
1. Extract the raw `sdb.tar.gz` and `satcat.zip` files.
2. Copy the contents securely into your Oracle container (`/opt/oracle/oradata/`).
3. Re-create the necessary Oracle Directory objects (`SDB`, `SDB_SDB`, `SPACE_OUTPUT_DIR`, `DATA_DUMP_DIR`) pointing to the correct container volume and apply the necessary `READ/WRITE` grants.
4. Download the missing `data_dump.sql` dependency and compile it.
5. Fix missing files (e.g., `lvtemplate`, `all`).
6. Apply `INHERIT PRIVILEGES` and correctly compile `space_exporter.pck`.

After running the script, you can execute `EXEC SPACE_EXPORTER.GENERATE_ORACLE_FILE;` without encountering the errors.

---

## Original Readme

Download the files as a zip using the green button, or clone the repository to your machine using Git.

## Releases

Release v1.0 corresponds to the code in the published book, without corrections or updates.

## Contributions

See the file Contributing.md for more information on how you can contribute to this repository.
