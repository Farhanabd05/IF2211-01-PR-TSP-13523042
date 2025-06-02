# TSP Solver – Pemrograman Dinamis (Perl)

Skrip Perl ini menerapkan pendekatan pemrograman dinamis untuk menyelesaikan Traveling Salesperson Problem (TSP). Program ini akan mencari rute dengan biaya minimum yang mengunjungi setiap kota tepat sekali dan kembali ke kota awal. Selain itu, skrip ini juga menghitung jumlah rute optimal yang ada.

## Fitur

* Menyelesaikan masalah TSP menggunakan pemrograman dinamis dengan bitmasking.  
* Mendukung dua format masukan untuk grafik:  
  * **Matriks persegi:** Menunjukkan biaya antara setiap pasangan kota.  
  * **Daftar sisi (edge list):** Menunjukkan koneksi langsung antara dua kota beserta bobot (biaya) masing-masing.  
* Bisa menangani grafik berarah (directed) maupun tak berarah (undirected) saat menggunakan daftar sisi.  
* Menghitung dan menampilkan biaya minimum untuk rute TSP.  
* Menghitung dan menampilkan jumlah total rute optimal.  
* Mencetak salah satu rute optimal yang ditemukan.  
* Mengukur dan menampilkan waktu eksekusi perhitungan.

## Cara Memulai

1. **Simpan Kode:** Simpan seluruh kode Perl ke dalam satu file, misalnya `main.pl`.  
2. **Pastikan Perl Terpasang:**  
   - Di Windows, Anda bisa menggunakan [Strawberry Perl](https://strawberryperl.com/) atau [ActivePerl](https://www.activestate.com/products/perl/).  
   - Di Linux/Mac umumnya Perl sudah tersedia secara bawaan. Untuk memastikan, buka terminal dan jalankan:  
     ```bash
     perl -v
     ```  
     Jika belum terinstal, pada distribusi Debian/Ubuntu gunakan `sudo apt install perl`, atau pada Fedora/CentOS gunakan `sudo dnf install perl`.

## Cara Menjalankan Program

### Di Windows

1. **Buka Command Prompt**  
   Tekan Win+R, ketik `cmd`, lalu tekan Enter.

2. **Arahkan ke Direktori Proyek**  
   Misal Anda menyimpan `main.pl` di folder `C:\TSP`, maka ketik:
   ```bat
   cd C:\TSP
   ```

3. **Jalankan Skrip Perl**  
   Ketik perintah berikut:
   ```bat
   perl main.pl
   ```
   Program akan meminta Anda memilih format masukan dan memasukkan data grafik sesuai petunjuk.

### Di Linux/Mac (Contoh Ubuntu/Debian)

1. **Buka Terminal**  
   Bisa dengan menekan `Ctrl+Alt+T` atau mencarinya di menu aplikasi.

2. **Arahkan ke Direktori Skrip**  
   Misal file `main.pl` berada di `~/projects/tsp`:
   ```bash
   cd ~/projects/tsp
   ```
3. **Jalankan Skrip**  
   Pastikan skrip bisa dieksekusi (jika perlu jalankan `chmod +x main.pl`), lalu:
   ```bash
   perl main.pl
   ```
   Ikuti petunjuk yang muncul di layar.

## Format Input

Setelah skrip dijalankan, Anda akan diminta memilih salah satu dari dua format masukan:

### 1. Input Matriks Persegi

1. Masukkan jumlah kota (N).  
2. Masukkan nilai matriks baris per baris (masing-masing berisi N angka), dipisah spasi.  
3. Nilai 0 (atau angka ≤ 0, selain diagonal) akan dianggap sebagai “infinity” (artinya tidak ada jalur langsung antar kota tersebut).

Contoh di layar:
```
==================================================
           TSP SOLVER USING DYNAMIC PROGRAMMING
==================================================

Available input formats:
  [1] Adjacency Matrix (N x N)
      → Enter matrix dimensions and values
  [2] Edge List (source destination weight)
      → Enter edges one by one, empty line to finish

Select input type (1 or 2): 1
Enter number of cities (N): 3
Enter the adjacency matrix (3 rows, 3 columns each):
Use 0 for no direct connection between different cities.

Row 1: 0 10 15
Row 2: 20 0 35
Row 3: 30 25 0

==================================================
                    SOLUTION RESULTS
==================================================

Minimum tour cost:      60.00
Number of optimal tours: 1
Execution time:         0.194 ms
Optimal tour:           0 -> 2 -> 1 -> 0

Path details:
  City 0 -> City 2: 15.00
  City 2 -> City 1: 25.00
  City 1 -> City 0: 20.00
  ------------------------------
  Total distance: 60.00
```

### 2. Input Daftar Sisi (Edge List)

1. Anda akan ditanya apakah sisi bersifat berarah (y/n).  
2. Masukkan setiap sisi dalam format `u v w` (u dan v = indeks kota, mulai dari 0; w = bobot/biaya).  
3. Tekan Enter pada baris kosong jika sudah selesai.

Contoh di layar:
```
=== TSP Solver ===
Pilih tipe input:
1. Matriks persegi (N x N)
   Masukkan nilai matriks setiap baris
2. Daftar sisi (u v w)
   Masukkan baris “u v w” satu per satu (baris kosong untuk selesai)
Pilih input (1/2): 2
Apakah sisi berarah? (y/n): n
Masukkan sisi (u v w), baris kosong untuk selesai:
0 1 10
1 2 35
2 0 30
0 2 15
1 0 20
2 1 25

```

## Hasil Output

Setelah memproses masukan dan menghitung solusi TSP, skrip akan menampilkan:

* Biaya minimum untuk rute TSP.  
* Jumlah rute optimal yang ditemukan.  
* Waktu eksekusi perhitungan (dalam milidetik).  
* Salah satu rute optimal (berurutan mulai dari kota 0, mengunjungi semua kota sekali, lalu kembali ke kota 0).

Contoh di layar:
```
==================================================
                    SOLUTION RESULTS
==================================================

Minimum tour cost:      60.00
Number of optimal tours: 1
Execution time:         0.194 ms
Optimal tour:           0 -> 2 -> 1 -> 0

Path details:
  City 0 -> City 2: 15.00
  City 2 -> City 1: 25.00
  City 1 -> City 0: 20.00
  ------------------------------
  Total distance: 60.00
```

## Cara Kerja Algoritma

Implementasi ini menggunakan pemrograman dinamis dengan bitmasking. Setiap keadaan (state) direpresentasikan oleh pasangan `(mask, u)`:

- `mask` adalah bitmask (integer) di mana bit ke-i bernilai 1 apabila kota i sudah dikunjungi.  
- `u` adalah kota terakhir yang dikunjungi pada state tersebut.

Kita menyimpan dua tabel utama:

1. **dp[u][mask]** = biaya minimum untuk memulai dari kota 0, mengunjungi semua kota dalam `mask`, lalu berakhir di kota `u`.  
2. **counts[u][mask]** = jumlah cara (rute) yang menghasilkan biaya `dp[u][mask]`.

### 1. Inisialisasi (Base Case)

Karena rute selalu dimulai di kota 0, maka keadaan awal adalah:

```
mask = 1 << 0  (hanya kota 0 yang sudah dikunjungi)
u = 0
dp[0][1] = 0
counts[0][1] = 1
```

Semua `dp[u][mask]` lainnya diinisialisasi ke “infinity” (tidak terjangkau).

### 2. Rumus Rekurensi

Untuk setiap bitmask `S` dan setiap kota `i` yang termasuk di dalam `S` (bit ke-i pada `S` = 1), kita hitung:

```
dp[i][S] = min{ dp[j][S_without_i] + C(j, i) }  untuk semua j ∈ S, j ≠ i
```

Di mana:  
- `S_without_i` adalah bitmask `S` dengan bit ke-i dimatikan (unset).  
- `C(j, i)` adalah biaya (weight) dari kota j ke kota i (diambil dari matriks atau daftar sisi).  
- Jika `C(j, i)` = infinite (tidak ada sisi langsung), abaikan transisi tersebut.

Saat menghitung `dp[i][S]`, kita juga memperbarui:

- Jika `dp[j][S_without_i] + C(j, i) < dp[i][S]`, maka set `counts[i][S] = counts[j][S_without_i]`.  
- Jika sama dengan `dp[i][S]`, maka tambahkan `counts[j][S_without_i]` ke `counts[i][S]`.

Proses ini diulang untuk semua `S` dengan urutan peningkatan jumlah bit 1 (submask paling kecil ke submask paling besar).

### 3. Menentukan Solusi Akhir

Setelah semua `dp[u][mask]` terisi, definisikan:

```
FULL = (1 << N) - 1   # bitmask di mana semua kota (0 sampai N-1) sudah ter-visit
```

Biaya total minimum untuk tour TSP adalah:

```
MinCost = min{ dp[i][FULL] + C(i, 0) }  untuk i = 1 … N-1
```

Karena rute harus kembali dari kota terakhir ke kota 0.

Jumlah rute optimal (`TotalOptimalPaths`) adalah penjumlahan `counts[i][FULL]` untuk semua `i` yang menghasilkan biaya `MinCost`.

## Lisensi

Proyek ini tersedia di bawah lisensi MIT.

---

**Author:** Abdullah Farhan
