from abc import ABC, abstractmethod

import numpy as np
import tensorflow as tf
import tensorflow.keras.backend as K
from tensorflow.keras.preprocessing.image import random_rotation


class InputModifier(ABC):
    """Abstract class for defining an input modifier.
    """
    @abstractmethod
    def __call__(self, seed_input):
        """Implement modification to the input before processing gradient descent.

        # Arguments:
            seed_input: An N-dim numpy array.
        # Returns:
            The modified `seed_input`.
        """
        raise NotImplementedError()


class Jitter(InputModifier):
    def __init__(self, jitter=0.05):
        """Implements an input modifier that introduces random jitter.
            Jitter has been shown to produce crisper activation maximization images.

        # Arguments:
            jitter: The amount of jitter to apply, scalar or sequence. If a scalar, same jitter is
                applied to all image dims. If sequence, `jitter` should contain a value per image
                dim. A value between `[0., 1.]` is interpreted as a percentage of the image
                dimension. (Default value: 0.05)
        """
        self.jitter = None
        self._jitter = jitter

    def __call__(self, seed_input):
        if self.jitter is None:
            shape = seed_input.shape[1:-1]
            self.axis = list(range(1, 1 + shape.rank))
            self.jitter = [
                dim * self._jitter if self._jitter < 1. else self._jitter for dim in shape
            ]
        return tf.roll(seed_input, [np.random.randint(-j, j + 1) for j in self.jitter], self.axis)


class Rotate(InputModifier):
    def __init__(self, degree=1.):
        """Implements an input modifier that introduces random rotation.
            Rotate has been shown to produce crisper activation maximization images.

        # Arguments:
            degree: The amount of rotation to apply.
        """
        self.rg = degree

    def __call__(self, seed_input):
        seed_input = [np.asarray(x) for x in seed_input]
        seed_input = [
            random_rotation(x, self.rg, row_axis=0, col_axis=1, channel_axis=2) for x in seed_input
        ]
        seed_input = [tf.expand_dims(x, axis=0) for x in seed_input]
        return K.concatenate(seed_input, axis=0)
