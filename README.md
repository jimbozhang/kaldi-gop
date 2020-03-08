# kaldi-gop
This project computes GMM-based GOP (Goodness of Pronunciation) using Kaldi.

## Notes about the DNN-based implementation

This implementation is GMM-based. For DNN-based implementation, please check Kaldi's official repository:
> https://github.com/kaldi-asr/kaldi/tree/master/egs/gop

The performance of GOP-DNN should be much better than GOP-GMM.

## How to build
```
./build.sh
```
## Run the example
```
cd egs/gop-compute
./run.sh
```

## Theory

In the conventional GMM-HMM based system, GOP was first proposed in (Witt et al., 2000). It was defined as the duration normalised log of the posterior:

$$
GOP(p)=\frac{1}{t_e-t_s+1} \log p(p|\mathbf o)
$$

where $\mathbf o$ is the input observations, $p$ is the canonical phone, $t_s, t_e$ are the start and end frame indexes.

Assuming $p(q_i)\approx p(q_j)$ for any $q_i, q_j$, we have:

$$
\log p(p|\mathbf o)=\frac{p(\mathbf o|p)p(p)}{\sum_{q\in Q} p(\mathbf o|q)p(q)}
                   \approx\frac{p(\mathbf o|p)}{\sum_{q\in Q} p(\mathbf o|q)}
$$

where $Q$ is the whole phone set.

The numerator of the equation is calculated from forced alignment result and the denominator is calculated from a Viterbi decoding with an unconstrained phone loop.
