import streamlit as st
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier

matches = pd.read_csv("final_data.csv")

matches["HomeTeam_code"] = matches["HomeTeam"].astype("category").cat.codes
matches["AwayTeam_code"] = matches["AwayTeam"].astype("category").cat.codes
matches["target"] = (matches["result"] == "Win").astype("int")

rf = RandomForestClassifier(n_estimators=50, min_samples_split=10, random_state=1)
train = matches[matches["Date"] < '2008-01-01']
test = matches[matches["Date"] > '2008-01-01']
predictors = ["HomeTeam_code", "AwayTeam_code", "FTHG", "home_total_goals_for_year"]
rf.fit(train[predictors], train["target"])

# Streamlit UI
st.title("⚽ La-Liga Soccer Match Predictor")

# Dropdowns for team selection
teams = sorted(matches["HomeTeam"].unique())  # Get unique teams
home_team = st.selectbox("Select Home Team", teams)
away_team = st.selectbox("Select Away Team", teams)

# Predict Button
if st.button("Predict Outcome"):
    # Encoding
    home_encoded = matches[matches["HomeTeam"] == home_team]["HomeTeam_code"].iloc[0]
    away_encoded = matches[matches["AwayTeam"] == away_team]["AwayTeam_code"].iloc[0]

    avg_home_goals_year = matches[matches["HomeTeam"] == home_team]["home_total_goals_for_year"].mean()

    # Feature vector
    feature_vector = pd.DataFrame([{
        'HomeTeam_code': home_encoded,
        'AwayTeam_code': away_encoded,
        'FTHG': np.random.randint(1,5),  # Default to 1 if no data
        'home_total_goals_for_year': avg_home_goals_year if not np.isnan(avg_home_goals_year) else 10
    }])

    # Prediction
    prediction = rf.predict(feature_vector)

    # Result Mapping
    result_map = {0: f"{home_team} will lose", 1: f"{home_team} will win"}
    st.success(f"🔮 {result_map[prediction[0]]}")

st.write("Powered using data from Kaggle")
