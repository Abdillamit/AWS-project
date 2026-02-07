interface AppState {
  initialized: boolean;
  loading: boolean;
}

const initialState: AppState = {
  initialized: false,
  loading: false,
};

type AppAction =
  | { type: 'APP_INIT' }
  | { type: 'APP_LOADING'; payload: boolean };

export const appReducer = (
  state: AppState = initialState,
  action: AppAction
): AppState => {
  switch (action.type) {
    case 'APP_INIT':
      return { ...state, initialized: true };
    case 'APP_LOADING':
      return { ...state, loading: action.payload };
    default:
      return state;
  }
};
