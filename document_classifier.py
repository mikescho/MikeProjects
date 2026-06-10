import marimo

__generated_with = "0.23.8"
app = marimo.App(width="medium")


@app.cell
def _():
    import marimo as mo
    import pandas as pd
    from sklearn.metrics import classification_report, f1_score, precision_score, recall_score
    from sklearn.linear_model import LogisticRegression
    from sentence_transformers import SentenceTransformer
    import joblib
    import numpy as np
    from sklearn.model_selection import train_test_split

    return (
        LogisticRegression,
        SentenceTransformer,
        classification_report,
        np,
        pd,
        train_test_split,
    )


@app.cell
def _(pd):
    original_df = pd.DataFrame(pd.read_excel('C:/Users/mikes/Desktop/Sample_WOS_Pull.xls')['Abstract'])
    return (original_df,)


@app.cell
def _(np, original_df):
    ## I made random labels here, but ideally we would make these manually before hand ##

    labels = np.random.choice([0, 1], size=50, p=[0.75, 0.25])
    labels.shape
    original_df['labels'] = labels
    return


@app.cell
def _(original_df):
    original_df
    return


@app.cell
def _(original_df, train_test_split):
    x_train, x_test, y_train, y_test = train_test_split(original_df['Abstract'],original_df['labels'],test_size=.2,stratify=original_df['labels'])
    return x_test, x_train, y_test, y_train


@app.cell
def _(SentenceTransformer):
    model = SentenceTransformer("BAAI/bge-base-en-v1.5")
    return (model,)


@app.cell
def _(model, x_train):
    x_train_embeddings = model.encode(x_train.tolist(),show_progress_bar=True)
    return (x_train_embeddings,)


@app.cell
def _(model, x_test):
    x_test_embeddings = model.encode(x_test.tolist(),show_progress_bar=True)
    return (x_test_embeddings,)


@app.cell
def _(LogisticRegression, x_train_embeddings, y_train):
    clf = LogisticRegression(max_iter=1000,class_weight='balanced')

    clf.fit(x_train_embeddings,y_train)
    return (clf,)


@app.cell
def _(clf, x_test_embeddings):
    preds = clf.predict(x_test_embeddings)
    return (preds,)


@app.cell
def _(classification_report, preds, y_test):
    print(classification_report(y_test,preds))
    return


@app.cell
def _(pd):
    testing_df = pd.DataFrame(pd.read_excel('C:/Users/mikes/Desktop/WOS_Pull_Test.xls')['Abstract'])

    ## this would be your link to the abstracts with no labels ##
    return (testing_df,)


@app.cell
def _(testing_df):
    testing_df
    return


@app.cell
def _(clf, model, testing_df):
    predictions = clf.predict(model.encode(testing_df['Abstract'].tolist(),show_progress_bar=True))
    return (predictions,)


@app.cell
def _(clf, model, testing_df):
    probabilities = clf.predict_proba(model.encode(testing_df['Abstract'].tolist(),show_progress_bar=True))[:,1]
    return (probabilities,)


@app.cell
def _(predictions, probabilities, testing_df):
    final_df = testing_df.assign(pred_label=predictions,probabilities_of_positive=probabilities)
    return (final_df,)


@app.cell
def _(final_df):
    final_df.sort_values(by="probabilities_of_positive",ascending=False,inplace=True)
    return


@app.cell
def _(final_df):
    for x in range(5):
        print(f'text: {final_df.iloc[x,0]}\nlabel:{final_df.iloc[x,1]}\nprob:{final_df.iloc[x,2]}')
    return


@app.cell
def _(final_df):
    final_df.groupby("pred_label")['Abstract'].count()
    return


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
