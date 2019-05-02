Before starting review/execute the [useful tips](useful.md).

#### Writing pipelines with SnakeMake

There is excellent [presentation](http://slides.com/johanneskoester/deck-1#/) made by snakemake authors, which you should read, since the code below closely follows it. Official [tutorial](https://snakemake.readthedocs.io/en/stable/tutorial/basics.html) describes more advanced example.

First, install SnakeMake:

```bash
conda activate envname
# In case you don't have it yet
conda install snakemake
```

##### Basic example

Let's start with very basic example - sorting some files.

```bash
mkdir snake_test
cd snake_test
# Following lines create two files with numbers randomly generated
# in a range from 1 to 10
python -c $'import random\nfor i in range(5): print(random.randint(1,10))' > A.txt
python -c $'import random\nfor i in range(5): print(random.randint(1,10))' > B.txt
```

The content of the A.txt:

```bash
(ngschool) aln@aln-vb:~/snake_test$ cat A.txt 
7
10
6
6
2
```

Create the file names `Snakefile` with the following content:

```bash
(ngschool) aln@aln-vb:~/snake_test$ cat Snakefile
rule sort:
    input:
        "A.txt"
    output:
        "A.sorted.txt"
    shell:
        "sort -n {input} > {output}"
```

If you run snakemake you should see following:

```bash
(ngschool) aln@aln-vb:~/snake_test$ snakemake
Provided cores: 1
Rules claiming more threads will be scaled down.
Job counts:
    count    jobs
    1    sort
    1

rule sort:
    input: A.txt
    output: A.sorted.txt
    jobid: 0

Finished job 0.
1 of 1 steps (100%) done
```

We also have new file in our folder:

```bash
(ngschool) aln@aln-vb:~/snake_test$ cat A.sorted.txt 
2
6
6
7
10
```

Now, let's modify Snakefile, so it will process both A and B files. By default snakemake executes the first rule in the snakefile. This gives rise to pseudo-rules at the beginning of the file that can be used to define build-targets similar to GNU Make. So, in a way in the `all` rule we request all the output files to be present, and Snakemake recognizes automatically that these can be created by multiple applications of the rule `sort`:

```bash
(ngschool) aln@aln-vb:~/snake_test$ cat Snakefile 
DATASETS = ["A", "B"]

rule all:
    input:
        expand("{dataset}.sorted.txt", dataset=DATASETS)

rule sort:
    input:
        "{dataset}.txt"
    output:
        "{dataset}.sorted.txt"
    shell:
        "sort -n {input} > {output}"
```

Try to execute snakemake again, you will see following:

```bash
(ngschool) aln@aln-vb:~/snake_test$ snakemake
Provided cores: 1
Rules claiming more threads will be scaled down.
Job counts:
    count    jobs
    1    all
    1    sort
    2

rule sort:
    input: B.txt
    output: B.sorted.txt
    jobid: 2
    wildcards: dataset=B

Finished job 2.
1 of 2 steps (50%) done

localrule all:
    input: A.sorted.txt, B.sorted.txt
    jobid: 0

Finished job 0.
2 of 2 steps (100%) done
```

But what is peculiar about this output? Rule `sort` sorted only B file, right? That's because we already sorted A and we have A output already in our folder. We can force all tasks execution and see if the output is different:

```bash
(ngschool) aln@aln-vb:~/snake_test$ snakemake -F
Provided cores: 1
Rules claiming more threads will be scaled down.
Job counts:
    count    jobs
    1    all
    2    sort
    3

rule sort:
    input: B.txt
    output: B.sorted.txt
    jobid: 2
    wildcards: dataset=B

Finished job 2.
1 of 3 steps (33%) done

rule sort:
    input: A.txt
    output: A.sorted.txt
    jobid: 1
    wildcards: dataset=A

Finished job 1.
2 of 3 steps (67%) done

localrule all:
    input: A.sorted.txt, B.sorted.txt
    jobid: 0

Finished job 0.
3 of 3 steps (100%) done
```

So, now we see that `sort` processed both A and B files.

> NB: `-f` flag will force execute firth rule regardless of the output, and `-F` will force execute all the rules.

Some more useful commands:

```bash
# execute the workflow with target A.sorted.txt
snakemake A.sorted.txt
# dry-run
snakemake -n
# dry-run, print shell commands
snakemake -n -p
# dry-run, print execution reason for each job
snakemake -n -r
```

Amazing feature of the snakemake is pipeline diagram plotting:

```bash
conda install Graphviz
snakemake --dag | dot -Tsvg > dag.svg
eog dag.svg
```

![](../../images/dag.svg)

How about some parallelization?

```bash
(ngschool) aln@aln-vb:~/snake_test$ cat Snakefile 
DATASETS = ["A", "B"]

rule all:
    input:
        expand("{dataset}.sorted.txt", dataset=DATASETS)

rule sort:
    input:
        "{dataset}.txt"
    output:
        "{dataset}.sorted.txt"
    threads: 4
    resources: mem_mb=100
    shell:
        "sort --parallel {threads} {input} > {output}"
```

Then we can start snakemake with the following parameters:

```bash
# Execute the workflow with 8 cores
snakemake --cores 8
# Prioritize the creation of a certain file
snakemake --prioritize A.sorted.txt --cores 8
# Execute the workflow with 8 cores and 100MB memory.
# Will execute only one job at a time, since in the Snakefile we set memory limit.
snakemake --cores 8 --resources mem_mb=100
```

Finally, we would want to read the input list from external file as the current design is not customizable enough. First, create config file:

```bash
(ngschool) aln@aln-vb:~/snake_test$ cat config.yaml 
datasets:
    A: A.txt
    B: B.txt
```

Then edit your `Snakefile` in a following way:

```bash
(ngschool) aln@aln-vb:~/snake_test$ cat Snakefile 
configfile: "config.yaml"

rule all:
    input:
        expand("{dataset}.sorted.txt", dataset=config["datasets"])

rule sort:
    input:
        "{dataset}.txt"
    output:
        "{dataset}.sorted.txt"
    threads: 4
    resources: mem_mb=100
    shell:
        "sort --parallel {threads} {input} > {output}"
```

And last, run snakemake:

```bash
snakemake -F
```

##### Advanced example

Run following commands:

```bash
source activate envname
conda install fastqc subversion
svn export https://github.com/sysbio-vo/sysbio-course/trunk/examples/snake_qc/
cd snake_qc/
mkdir raws
mkdir fastqc
cd raws
# From http://www.ebi.ac.uk/ena/data/view/SRR1750053
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR175/003/SRR1750053/SRR1750053_1.fastq.gz
wget ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR175/003/SRR1750053/SRR1750053_2.fastq.gz
cd ..
snakemake -s workflows/qc.wf -p --configfile configs/config.yaml --cores 4 -r
ls fastqc/
snakemake --dag -s workflows/qc.wf --configfile configs/config.yaml | dot -Tsvg > dag.svg
eog dag.svg
```

Check fastqc html report. What can you tell about it? Closely examine rules and workflows folders. What is different about this snakemake workflow design if you compare with previous simple example?

Useful links:

* [https://github.com/SnakeChunks/SnakeChunks](https://github.com/SnakeChunks/SnakeChunks)
* [https://github.com/crazyhottommy/ChIP-seq-analysis/tree/master/snakemake\_ChIPseq\_pipeline](https://github.com/crazyhottommy/ChIP-seq-analysis/tree/master/snakemake_ChIPseq_pipeline)
* [http://metagenomic-methods-for-microbial-ecologists.readthedocs.io/en/latest/day-1/](http://metagenomic-methods-for-microbial-ecologists.readthedocs.io/en/latest/day-1/)
* [http://archive.is/Q6VPB](http://archive.is/Q6VPB)