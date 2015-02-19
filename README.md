# drug-trial dataset

Three intersecting MySQL test datasets extracted from real sources ([Clinical Trials][ct],
[Drug Bank][db] and the [Therapeutic Target Database][ttd]). Each dataset is generated based on a
partial snapshot of the source, taken at an unspecified point in time.
They are intended for testing purposes only and are not up to date, complete or correct.

The migration scripts are available in the [github repository][repo].

## Terms and Conditions

### Use of ClinicalTrials.gov Data

Neither the United States Government, U.S. Department of Health and Human Services, National Institutes
of Health, National Library of Medicine, nor any of its agencies, contractors, subcontractors or employees
of the United States Government make any warranties, expressed or implied, with respect to data contained
in the database, and, furthermore, assume no liability for any party's use, or the results of such use,
of any part of the database.

In any publication or distribution of these data, you should:

  - Attribute the source of the data as ClinicalTrials.gov
  - Update the data such that they are current at all times
  - Clearly display the date the data were processed by ClinicalTrials.gov
  - State any modifications made to the content of the data, along with a complete description of the modifications

You shall not assert any proprietary rights to any portion of the database, or represent the database or any
part thereof to anyone as other than a United States Government database.

You shall not use any email addresses extracted from our database for marketing or other promotional purposes.

The ClinicalTrials.gov data carry an international copyright outside the United States and its Territories
or Possessions. Some ClinicalTrials.gov data may be subject to the copyright of third parties; you should
consult these entities for any additional terms of use.

### Use of DrugBank data

DrugBank is offered to the public as a freely available resource. Use and re-distribution of the data,
in whole or in part, for commercial purposes requires explicit permission of the authors and explicit
acknowledgment of the source material (DrugBank) and the original publication (see below).
We ask that users who download significant portions of the database cite the DrugBank paper in any resulting publications.

**Disclaimer**: The content of DrugBank is intended for educational and scientific research purposes only.
It is not intended as a substitute for professional medical advice, diagnosis or treatment.

## References

 - DrugBank 4.0: shedding new light on drug metabolism. Law V, Knox C, Djoumbou Y, Jewison T, Guo AC, Liu Y, Maciejewski A, Arndt D, Wilson M, Neveu V, Tang A, Gabriel G, Ly C, Adamjee S, Dame ZT, Han B, Zhou Y, Wishart DS.Nucleic Acids Res. 2014 Jan 1;42(1):D1091-7.
   PubMed ID: 24203711
 - Zhu F, Shi Z, Qin C, Tao L, Liu X, Xu F, Zhang L, Song Y, Liu XH, Zhang JX, Han BC, Zhang P, Chen YZ. Therapeutic target database update 2012: a resource for facilitating target-oriented drug discovery. Nucleic Acids Res. 40(D1): D1128-1136, 2012. PubMed.

[ct]: http://clinicaltrials.gov/ "ClinicalTrials.gov"
[db]: http://www.drugbank.ca/ "DrugBank"
[ttd]: http://bidd.nus.edu.sg/group/cjttd/ "Therapeutic Target Database"
[repo]: https://github.com/pyranja/drug-trials "source repository"
