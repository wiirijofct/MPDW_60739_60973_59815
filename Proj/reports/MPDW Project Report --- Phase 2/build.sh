#!/bin/bash

# Create output directory if it doesn't exist
mkdir -p ../output

cd manuscript
export TEXINPUTS=.:../style:$TEXINPUTS
echo "Compiling LaTeX document..."

# Generate directly to output folder
pdflatex -interaction=nonstopmode -output-directory=../output MPDW_Report_2

# Only run bibtex if there are citations
if grep -q "\\\\cite" MPDW_Report_2.tex; then
  echo "Processing bibliography..."
  # Run bibtex in the output directory
  cd ../output
  bibtex MPDW_Report_2
  cd ../manuscript
  
  # Run pdflatex again with output directory set
  pdflatex -interaction=nonstopmode -output-directory=../output MPDW_Report_2
fi

# Final compilation to output directory
pdflatex -interaction=nonstopmode -output-directory=../output MPDW_Report_2

# Compare PDFs if both exist
if [ -f "MPDW_Report_2.pdf" ] && [ -f "../output/MPDW_Report_2.pdf" ]; then
  echo "Comparing PDFs..."
  # Check if pdftk or diff is available for comparison
  if command -v pdftk &> /dev/null; then
    # Use pdftk to get info and compare
    pdf1_info=$(pdftk MPDW_Report_2.pdf dump_data | grep -E "NumberOfPages|ModDate")
    pdf2_info=$(pdftk ../output/MPDW_Report_2.pdf dump_data | grep -E "NumberOfPages|ModDate")
    
    if [ "$pdf1_info" == "$pdf2_info" ]; then
      echo "PDFs appear to be identical (same page count and modification date)"
    else
      echo "PDFs differ in page count or modification date!"
    fi
  elif command -v diff &> /dev/null && command -v pdftotext &> /dev/null; then
    # Convert both to text and diff them (less reliable but works in a pinch)
    pdftotext MPDW_Report_2.pdf - > /tmp/pdf1.txt
    pdftotext ../output/MPDW_Report_2.pdf - > /tmp/pdf2.txt
    
    if diff -q /tmp/pdf1.txt /tmp/pdf2.txt &> /dev/null; then
      echo "PDF text content appears identical"
    else
      echo "PDF text content differs!"
    fi
    
    # Clean up temp files
    rm -f /tmp/pdf1.txt /tmp/pdf2.txt
  else
    echo "No PDF comparison tools available. Install pdftk or pdftotext for comparison."
    echo "Simply checking file sizes:"
    size1=$(stat -c%s "MPDW_Report_2.pdf")
    size2=$(stat -c%s "../output/MPDW_Report_2.pdf")
    
    if [ "$size1" == "$size2" ]; then
      echo "PDFs have identical file sizes."
    else
      echo "PDFs have different file sizes: manuscript($size1 bytes), output($size2 bytes)"
    fi
  fi
  
  # Remove manuscript PDF after comparison as it's redundant
  echo "Removing duplicate PDF from manuscript folder..."
  rm -f MPDW_Report_2.pdf
else
  # If only manuscript PDF exists, move it to output
  if [ -f "MPDW_Report_2.pdf" ] && [ ! -f "../output/MPDW_Report_2.pdf" ]; then
    echo "Moving PDF from manuscript folder to output folder..."
    mv MPDW_Report_2.pdf ../output/
  fi
fi

# Clean up temp files from manuscript directory
echo "Cleaning up temporary files in manuscript directory..."
find . -name "*.aux" -o -name "*.log" -o -name "*.out" -o -name "*.bbl" -o -name "*.blg" -o -name "*.fls" -o -name "*.fdb_latexmk" -o -name "*.toc" -o -name "*.synctex.gz" | xargs rm -f 2>/dev/null

# Clean up temp files from output directory (excluding PDF)
echo "Cleaning up temporary files in output directory..."
find ../output -type f ! -name "*.pdf" | xargs rm -f 2>/dev/null

echo "Done! Final PDF is in the output directory."