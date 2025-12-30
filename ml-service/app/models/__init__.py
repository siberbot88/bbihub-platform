class MLModel:
    def __init__(self, db_config=None):
        self.db_config = db_config

    def train(self):
        raise NotImplementedError

    def predict(self):
        raise NotImplementedError

    def save(self):
        pass

    def load(self):
        pass
