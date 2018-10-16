### Environmental metagenomics data analysis


Access the virtual machine:

```bash
ssh -p [port] [user]@[ip]
screen -S [sessionname]
```

Check what your home folder, it is pretty much empty:
```bash
pwd
ls -al
```

We definitely need to configure shared conda environment as described in the [useful tips](useful.md). Activate the environment and check if you can run installed software:

```bash
(kau) aln@edu-af-01$ trim_galore 
No quality encoding type selected. Assuming that the data provided uses Sanger encoded Phred scores (default)


Please provide the filename(s) of one or more FastQ file(s) to launch Trim Galore!

USAGE:  'trim_galore [options] <filename(s)>'    or    'trim_galore --help'    for more options
```


Check data folder, what kind of files it contains? 
```bash
ls /storage/kau/data/
```

**The data analysis workflow is following:**
1. Quality control with [fastqc](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
2. Quality control reports aggregation with [multiqc](https://multiqc.info/)
3. If the quality is not satisfactory — trimming with [trim_galore](https://github.com/FelixKrueger/TrimGalore) (minimum length of the read is 70, quality threashold — 20)
4. OTU ([operational taxonomic unit](https://en.wikipedia.org/wiki/Operational_taxonomic_unit)) calling with [MetaPhlan2](http://huttenhower.sph.harvard.edu/metaphlan2)
5. Summary plots generation with [Krona](https://github.com/marbl/Krona/wiki)
6. Basic analysis in `R` with [ggplots2](https://ggplot2.tidyverse.org/)

We can start with [advanced snakemake example](workflows.md#advanced-example) to produce `fastqc` report, modifying it to contain more rules for our workflow.