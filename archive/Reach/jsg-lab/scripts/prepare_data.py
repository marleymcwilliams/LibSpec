import os, numpy as np, pandas as pd
os.makedirs("data/processed", exist_ok=True)
pd.DataFrame(np.zeros((1000,2)), columns=["x1","x2"]).to_parquet("data/processed/stream.parquet")

