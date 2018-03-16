# File Compression Application 

## Summary 
The application is created in Ruby and its purpose is for compressing and decompressing text files. This is done by using Abraham Lempel and Jacob Ziv loseless data compression algorithm in 1977, which is a dictionary coder and also is a sliding window algorithm. 

## Installion 
`git clone https://github.com/jasonkwok/File-Compression.git`

## Usage 
Simple as 

`make squeeze file={file path}` <br> 
to compress, which will output a `compressed.txt` file 

and

`make expand file={file path}` <br> 
to decompress, which will output a `decompressed.txt` file 

